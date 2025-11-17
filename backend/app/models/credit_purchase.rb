class CreditPurchase < ApplicationRecord
  belongs_to :credit_card
  belongs_to :user
  has_many :debt_payments, dependent: :destroy

  # Validations
  validates :concept, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :monthly_payment, presence: true, numericality: { greater_than: 0 }
  validates :total_months, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :purchase_date, presence: true
  validates :remaining_balance, numericality: { greater_than_or_equal_to: 0 }
  validates :paid_months, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :set_initial_remaining_balance, on: :create
  after_initialize :set_defaults, if: :new_record?

  # Scopes
  scope :active, -> { where(fully_paid: false) }
  scope :fully_paid, -> { where(fully_paid: true) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_card, ->(card_id) { where(credit_card_id: card_id) }
  scope :by_date_range, ->(start_date, end_date) { where(purchase_date: start_date..end_date) }

  # Instance methods
  def remaining_months
    total_months - paid_months
  end

  def progress_percentage
    return 100 if total_months.zero?
    ((paid_months.to_f / total_months) * 100).round(2)
  end

  def next_payment_due_date
    return nil if fully_paid?
    # Calcula la fecha del próximo pago basado en el corte de la tarjeta
    months_ahead = paid_months + 1
    purchase_date + months_ahead.months
  end

  def mark_as_paid!
    update!(fully_paid: true, remaining_balance: 0, paid_months: total_months)
  end

  def record_payment(amount, payment_date, notes: nil)
    return false if fully_paid?

    payment = debt_payments.create!(
      amount: amount,
      payment_date: payment_date,
      payment_number: paid_months + 1,
      notes: notes
    )

    new_balance = [remaining_balance - amount, 0].max
    new_paid_months = paid_months + 1
    is_fully_paid = new_balance.zero? || new_paid_months >= total_months

    update!(
      remaining_balance: new_balance,
      paid_months: new_paid_months,
      fully_paid: is_fully_paid
    )

    payment
  end

  private

  def set_initial_remaining_balance
    self.remaining_balance ||= total_amount
  end

  def set_defaults
    self.paid_months ||= 0
    self.fully_paid ||= false
  end
end
