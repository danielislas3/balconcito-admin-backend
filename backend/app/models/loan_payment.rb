class LoanPayment < ApplicationRecord
  belongs_to :loan

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_date, presence: true
  validates :payment_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :payment_number, uniqueness: { scope: :loan_id, message: "ya existe para este préstamo" }

  # Scopes
  scope :by_date_range, ->(start_date, end_date) { where(payment_date: start_date..end_date) }
  scope :recent, -> { order(payment_date: :desc) }

  # Instance methods
  def display_info
    "Pago ##{payment_number} - $#{amount} - #{payment_date.strftime('%d/%m/%Y')}"
  end

  def lender_name
    loan.lender.name
  end
end
