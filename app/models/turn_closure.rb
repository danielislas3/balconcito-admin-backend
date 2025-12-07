class TurnClosure < ApplicationRecord
  belongs_to :user, optional: true
  has_one :loyverse_shift, dependent: :nullify
  has_many :loyverse_receipts, dependent: :nullify

  # Store validation results as JSON
  # {
  #   valid: true/false,
  #   has_warnings: true/false,
  #   errors: [...],
  #   warnings: [...],
  #   validated_at: timestamp
  # }
  # JSONB field - no coder needed, Rails handles it natively
  attribute :validation_data, :jsonb, default: -> { {} }

  # Accessors for validation data
  def validation_errors
    validation_data["errors"] || []
  end

  def validation_errors=(value)
    validation_data["errors"] = value
  end

  def validation_warnings
    validation_data["warnings"] || []
  end

  def validation_warnings=(value)
    validation_data["warnings"] = value
  end

  # Validations
  validates :closure_number, presence: true, uniqueness: true
  validates :closure_date, presence: true
  validates :cash_collected, :card_income_gross, :transfer_income_gross,
            :total_income, numericality: { greater_than_or_equal_to: 0 }

  # Custom validations
  validate :validate_total_matches_payments, on: :create
  validate :validate_against_loyverse, if: :should_validate_loyverse?, on: :create

  # Scopes
  scope :by_date_range, ->(start_date, end_date) { where(closure_date: start_date..end_date) }
  scope :validated, -> { where.not(validated_at: nil) }
  scope :unvalidated, -> { where(validated_at: nil) }
  scope :with_errors, -> { where("(validation_data->>'has_errors')::boolean = true") }
  scope :with_warnings, -> { where("(validation_data->>'has_warnings')::boolean = true") }

  # Callbacks
  after_create :update_account_balances
  after_update :update_account_balances

  # Instance methods

  # Total de ingresos (debe coincidir con suma de métodos de pago)
  def calculated_total_income
    cash_collected + card_income_gross + transfer_income_gross
  end

  # Valida contra Loyverse y retorna resultado completo
  def validate_with_loyverse(loyverse_shift = nil)
    validator = TurnClosures::Validator.new(self, loyverse_shift)
    result = validator.validate

    # Guardar resultados de validación
    update_columns(
      validation_data: result.except(:shift_data, :reported_data),
      validated_at: Time.current,
      has_errors: !result[:valid],
      has_warnings: result[:has_warnings]
    )

    result
  end

  # ¿Tiene errores de validación?
  def has_validation_errors?
    has_errors == true
  end

  # ¿Tiene warnings de validación?
  def has_validation_warnings?
    has_warnings == true
  end

  # ¿Fue validado contra Loyverse?
  def validated?
    validated_at.present?
  end

  # ¿Fue creado automáticamente desde Loyverse?
  def from_loyverse?
    loyverse_shift.present?
  end

  # ¿Fue creado manualmente?
  def manual?
    !from_loyverse?
  end

  # Status de validación
  def validation_status
    return "not_validated" unless validated?
    return "error" if has_validation_errors?
    return "warning" if has_validation_warnings?
    "valid"
  end

  # Obtener discrepancias
  def discrepancies
    return {} unless validation_data.present?
    validation_data["discrepancies"] || {}
  end

  private

  # Validación: Total reportado debe coincidir con suma de métodos de pago
  def validate_total_matches_payments
    calculated = calculated_total_income
    diff = (total_income - calculated).abs

    if diff > 0.01 # Tolerancia de 1 centavo por redondeo
      errors.add(
        :total_income,
        "no coincide con suma de métodos de pago ($#{calculated}). Diferencia: $#{diff.round(2)}"
      )
    end
  end

  # Validación: Comparar contra datos de Loyverse
  def validate_against_loyverse
    validator = TurnClosures::Validator.new(self)
    result = validator.validate

    # Si hay errores críticos, bloquear creación
    if result[:errors].any? { |e| e[:severity] == "critical" }
      result[:errors].each do |error|
        errors.add(:base, error[:message])
      end
    end

    # Guardar warnings pero permitir creación
    if result[:warnings].any?
      self.validation_data = result.except(:shift_data, :reported_data)
      self.has_warnings = true
    end

    self.validated_at = Time.current if result[:valid] || result[:warnings].any?
  end

  # ¿Debe validar contra Loyverse?
  def should_validate_loyverse?
    # Solo validar si es creación manual (no desde webhook)
    # y si está habilitado el strict_validation
    ENV["LOYVERSE_STRICT_VALIDATION"] == "true" && !from_loyverse?
  end

  def update_account_balances
    # Actualizar Bóveda (efectivo)
    vault = Account.find_by(account_type: "vault")
    if vault
      vault.increment!(:balance, cash_collected)
    end

    # Actualizar Mercado Pago (tarjetas + transferencias)
    mercadopago = Account.find_by(account_type: "bank", name: "Mercado Pago")
    if mercadopago
      digital_income = card_income_gross + transfer_income_gross
      mercadopago.increment!(:balance, digital_income)
    end
  end
end
