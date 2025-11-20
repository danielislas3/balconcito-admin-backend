class CreditCard < ApplicationRecord
  belongs_to :user
  has_many :credit_purchases, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: "ya existe para este usuario" }
  validates :bank_name, presence: true
  validates :cut_day, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 31 }
  validates :credit_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  # Instance methods
  def total_debt
    credit_purchases.where(fully_paid: false).sum(:remaining_balance)
  end

  def monthly_commitment
    credit_purchases.where(fully_paid: false).sum(:monthly_payment)
  end

  def available_credit
    return 0 if credit_limit.nil? || credit_limit.zero?
    credit_limit - total_debt
  end

  def credit_utilization_percentage
    return 0 if credit_limit.nil? || credit_limit.zero?
    ((total_debt / credit_limit) * 100).round(2)
  end

  def display_name
    "#{name} - #{bank_name}"
  end

  def active_purchases_count
    credit_purchases.where(fully_paid: false).count
  end
end
