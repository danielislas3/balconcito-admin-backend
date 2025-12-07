class Loan < ApplicationRecord
  belongs_to :lender
  has_many :loan_payments, dependent: :destroy

  # Validations
  validates :principal_amount, presence: true, numericality: { greater_than: 0 }
  validates :interest_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :term_months, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :loan_date, presence: true
  validates :remaining_balance, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :set_initial_remaining_balance, on: :create
  before_validation :calculate_due_date, on: :create
  after_initialize :set_defaults, if: :new_record?

  # Scopes
  scope :active, -> { where(is_paid: false) }
  scope :paid, -> { where(is_paid: true) }
  scope :by_lender, ->(lender_id) { where(lender_id: lender_id) }
  scope :by_date_range, ->(start_date, end_date) { where(loan_date: start_date..end_date) }
  scope :with_interest, -> { where("interest_rate > ?", 0) }
  scope :interest_free, -> { where(interest_rate: 0) }

  # Instance methods
  def monthly_payment
    return 0 if term_months.zero?

    if interest_rate.zero?
      # Sin intereses: monto principal / meses
      (principal_amount / term_months).round(2)
    else
      # Con intereses: fórmula de amortización
      monthly_rate = interest_rate / 100 / 12
      numerator = principal_amount * monthly_rate * ((1 + monthly_rate) ** term_months)
      denominator = ((1 + monthly_rate) ** term_months) - 1
      (numerator / denominator).round(2)
    end
  end

  def total_amount_with_interest
    if interest_rate.zero?
      principal_amount
    else
      monthly_payment * term_months
    end
  end

  def total_interest
    total_amount_with_interest - principal_amount
  end

  def progress_percentage
    return 100 if principal_amount.zero?
    paid_amount = principal_amount - remaining_balance
    ((paid_amount / principal_amount) * 100).round(2)
  end

  def payments_made_count
    loan_payments.count
  end

  def payments_remaining
    [ term_months - payments_made_count, 0 ].max
  end

  def mark_as_paid!
    update!(is_paid: true, remaining_balance: 0)
  end

  def record_payment(amount, payment_date, notes: nil)
    return false if is_paid?

    payment = loan_payments.create!(
      amount: amount,
      payment_date: payment_date,
      payment_number: payments_made_count + 1,
      notes: notes
    )

    new_balance = [ remaining_balance - amount, 0 ].max
    is_now_paid = new_balance.zero?

    update!(
      remaining_balance: new_balance,
      is_paid: is_now_paid
    )

    payment
  end

  def next_payment_due_date
    return nil if is_paid?
    return due_date if payments_made_count.zero?

    # Próxima fecha de pago (asumiendo pagos mensuales)
    loan_date + (payments_made_count + 1).months
  end

  def is_overdue?
    return false if is_paid?
    return false if due_date.nil?
    Date.today > due_date
  end

  def days_until_due
    return 0 if is_paid? || due_date.nil?
    (due_date - Date.today).to_i
  end

  private

  def set_initial_remaining_balance
    self.remaining_balance ||= principal_amount
  end

  def calculate_due_date
    return if loan_date.nil? || term_months.nil?
    self.due_date ||= loan_date + term_months.months
  end

  def set_defaults
    self.interest_rate ||= 0
    self.is_paid ||= false
  end
end
