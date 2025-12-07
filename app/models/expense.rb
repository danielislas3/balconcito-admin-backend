class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :payment_method, optional: true
  has_many :reimbursement_expenses, dependent: :restrict_with_error
  has_many :reimbursements, through: :reimbursement_expenses

  # Enums
  enum :category, {
    # COGS (Cost of Goods Sold) - Costo de lo que vendes
    beer: "cerveza",
    draft_beer: "cerveza_barril",
    wines_liquors: "vinos_licores",
    sodas_juices: "refrescos_jugos",
    food: "alimentos",
    disposables: "desechables",
    ice: "hielo",
    dry_supplies: "insumos_secos",

    # Costos Fijos
    rent: "renta",
    payroll: "nomina",
    utilities: "servicios", # luz, agua, gas
    financial: "gastos_financieros", # comisiones Mercado Pago
    debt_payment: "pago_deuda",

    # Costos Variables
    maintenance: "mantenimiento",
    staff_expenses: "gastos_staff",
    miscellaneous: "gastos_varios",

    # CAPEX (Capital Expenditures) - Inversión inicial
    equipment: "equipo",
    construction_materials: "materiales",
    initial_inventory: "insumos",
    marketing: "marketing",
    office: "oficina",
    transportation: "transporte",
    others: "otros"
  }, validate: true

  # Validations
  validates :expense_date, :amount, :description, :category, presence: true
  validates :amount, numericality: { greater_than: 0 }

  # Scopes
  scope :pending_reimbursement, -> { where(requires_reimbursement: true, reimbursed: false) }
  scope :by_date_range, ->(start_date, end_date) { where(expense_date: start_date..end_date) }

  # Callbacks
  before_create :check_if_requires_reimbursement
  after_create :update_account_balance

  # Instance methods
  def cost_type
    case category.to_sym
    when :beer, :draft_beer, :wines_liquors, :sodas_juices, :food,
         :disposables, :ice, :dry_supplies
      "cogs" # Cost of Goods Sold
    when :rent, :payroll, :utilities, :financial, :debt_payment
      "fixed" # Costos Fijos
    when :maintenance, :staff_expenses, :miscellaneous
      "variable" # Costos Variables
    when :equipment, :construction_materials, :initial_inventory, :marketing,
         :office, :transportation, :others
      "capex" # Capital Expenditures (Inversión inicial)
    end
  end

  # Instance methods
  def payment_source_name
    payment_method&.name || "No especificado"
  end

  def paid_by_user
    payment_method&.user || user
  end

  private

  def check_if_requires_reimbursement
    # Si tiene payment_method, usar su configuración requires_reimbursement
    # Si no tiene payment_method, asumir que es del negocio (no requiere reembolso)
    self.requires_reimbursement = payment_method&.requires_reimbursement || false
  end

  def update_account_balance
    return if requires_reimbursement # Las tarjetas personales no afectan cuentas del negocio
    return unless payment_method&.business_owned? # Solo procesar si es método del negocio

    account = case payment_method.payment_type.to_sym
    when :business_cash then
                # Determinar si es caja chica o bóveda según el nombre del payment_method
                if payment_method.name.downcase.include?("caja")
                  Account.find_by(account_type: "petty_cash")
                else
                  Account.find_by(account_type: "physical_cash")
                end
    when :business_transfer then Account.find_by(name: "Mercado Pago")
    when :business_card then nil # TODO: Implementar tarjeta de crédito del negocio
    end

    account&.decrement!(:current_balance, amount)
  end
end
