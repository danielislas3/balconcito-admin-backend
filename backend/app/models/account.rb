class Account < ApplicationRecord
  # Associations
  has_many :reimbursements, foreign_key: 'from_account_id', dependent: :restrict_with_error

  # Enums
  enum :account_type, {
    digital: 'digital',           # Mercado Pago
    physical_cash: 'physical_cash', # Bóveda
    petty_cash: 'petty_cash'        # Caja Chica
  }, validate: true

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :account_type, presence: true
  validates :current_balance, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :total_balance, -> { sum(:current_balance) }
end
