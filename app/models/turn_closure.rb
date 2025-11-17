class TurnClosure < ApplicationRecord
  belongs_to :user

  # Validations
  validates :closure_number, presence: true, uniqueness: true
  validates :report_date, presence: true
  validates :closed_by, presence: true
  validates :cash_collected, :transfer_income, :card_income,
            :theoretical_cash, :payments_withdrawals,
            numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :by_date_range, ->(start_date, end_date) { where(report_date: start_date..end_date) }

  # Callbacks
  after_create :update_account_balances
  after_update :update_account_balances

  # Instance methods
  def total_income
    cash_collected + transfer_income + card_income
  end

  private

  def update_account_balances
    # Actualizar Caja Chica
    petty_cash = Account.find_by(account_type: 'petty_cash')
    if petty_cash
      petty_cash.update(
        current_balance: 1000 + cash_collected - payments_withdrawals
      )
    end

    # Actualizar Mercado Pago
    # Nota: En Milestone 2 aquí se restará la comisión de tarjeta
    mercadopago = Account.find_by(name: 'Mercado Pago')
    if mercadopago
      mercadopago.increment!(:current_balance, transfer_income + card_income)
    end
  end
end
