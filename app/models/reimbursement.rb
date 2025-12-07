class Reimbursement < ApplicationRecord
  belongs_to :to_user, class_name: "User" # A quién se le paga
  belongs_to :from_account, class_name: "Account" # De qué cuenta sale
  belongs_to :user # Quién registró el reembolso

  has_many :reimbursement_expenses, dependent: :destroy
  has_many :expenses, through: :reimbursement_expenses

  # Validations
  validates :reimbursement_date, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }

  # Callbacks
  after_create :mark_expenses_as_reimbursed
  after_create :update_account_balance

  private

  def mark_expenses_as_reimbursed
    expenses.update_all(reimbursed: true)
  end

  def update_account_balance
    from_account.decrement!(:current_balance, amount)
  end
end
