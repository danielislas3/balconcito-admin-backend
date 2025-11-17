require 'rails_helper'

RSpec.describe TurnClosure, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      turn_closure = build(:turn_closure)
      expect(turn_closure).to be_valid
    end

    it 'is not valid without closure_number' do
      turn_closure = build(:turn_closure, closure_number: nil)
      expect(turn_closure).not_to be_valid
    end

    it 'is not valid without report_date' do
      turn_closure = build(:turn_closure, report_date: nil)
      expect(turn_closure).not_to be_valid
    end

    it 'is not valid without closed_by' do
      turn_closure = build(:turn_closure, closed_by: nil)
      expect(turn_closure).not_to be_valid
    end

    it 'is not valid with negative amounts' do
      turn_closure = build(:turn_closure, cash_collected: -100)
      expect(turn_closure).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'scopes' do
    let!(:closure1) { create(:turn_closure, report_date: Date.new(2025, 1, 15)) }
    let!(:closure2) { create(:turn_closure, report_date: Date.new(2025, 1, 20)) }
    let!(:closure3) { create(:turn_closure, report_date: Date.new(2025, 2, 5)) }

    it 'filters by date range' do
      start_date = Date.new(2025, 1, 1)
      end_date = Date.new(2025, 1, 31)

      closures = TurnClosure.by_date_range(start_date, end_date)

      expect(closures).to include(closure1, closure2)
      expect(closures).not_to include(closure3)
    end
  end

  describe '#total_income' do
    it 'calculates total income correctly' do
      turn_closure = build(:turn_closure,
        cash_collected: 1000,
        transfer_income: 500,
        card_income: 300
      )

      expect(turn_closure.total_income).to eq(1800)
    end
  end

  describe 'callbacks' do
    let!(:petty_cash) { create(:account, :caja_chica, current_balance: 1000) }
    let!(:mercadopago) { create(:account, name: 'Mercado Pago', account_type: 'digital', current_balance: 0) }

    it 'updates account balances after create' do
      create(:turn_closure,
        cash_collected: 500,
        transfer_income: 300,
        card_income: 200,
        payments_withdrawals: 100
      )

      petty_cash.reload
      mercadopago.reload

      expect(petty_cash.current_balance).to eq(1400) # 1000 + 500 - 100
      expect(mercadopago.current_balance).to eq(500) # 0 + 300 + 200
    end
  end
end
