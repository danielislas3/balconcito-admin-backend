class LoyverseShift < ApplicationRecord
  # Asociaciones
  belongs_to :turn_closure, optional: true
  has_many :loyverse_receipts, foreign_key: :loyverse_shift_id, dependent: :nullify

  # Validaciones
  validates :loyverse_id, presence: true, uniqueness: true
  validates :gross_sales, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :cash_payments, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :recent, -> { order(closed_at: :desc) }
  scope :without_turn_closure, -> { where(turn_closure_id: nil) }
  scope :with_turn_closure, -> { where.not(turn_closure_id: nil) }

  # Calcula los totales por tipo de pago sumando los receipts asociados
  # Esto es la clave de la estrategia híbrida: el shift trae metadata,
  # pero los receipts traen el desglose exacto por payment_type
  def calculate_payment_totals
    return default_payment_totals if loyverse_receipts.empty?

    {
      cash: loyverse_receipts.sum(&:cash_total),
      card: loyverse_receipts.sum(&:card_total),
      custom: loyverse_receipts.sum(&:custom_payment_total),
      total: loyverse_receipts.sum { |r| r.total_money.to_f }
    }
  end

  # Verifica si hay diferencia de efectivo (faltante o sobrante)
  def cash_difference
    return 0 if expected_cash.nil? || actual_cash.nil?
    actual_cash - expected_cash
  end

  # Verifica si el cuadre de caja está correcto
  def cash_balanced?
    cash_difference.zero?
  end

  # Estado del cuadre
  def cash_status
    diff = cash_difference
    return "balanced" if diff.zero?
    diff.positive? ? "surplus" : "shortage"
  end

  # Verifica si ya fue convertido a TurnClosure
  def converted?
    turn_closure_id.present?
  end

  # Duración del turno en horas
  def duration_hours
    return 0 if opened_at.nil? || closed_at.nil?
    ((closed_at - opened_at) / 1.hour).round(2)
  end

  # Ventas promedio por hora
  def sales_per_hour
    hours = duration_hours
    return 0 if hours.zero?
    (gross_sales / hours).round(2)
  end

  # Nombre descriptivo del turno
  def display_name
    return "Turno #{loyverse_id[0..7]}" if closed_at.nil?
    "Turno #{closed_at.strftime('%d/%m/%Y %H:%M')}"
  end

  private

  def default_payment_totals
    {
      cash: cash_payments || 0,
      card: 0,
      custom: 0,
      total: gross_sales || 0
    }
  end
end
