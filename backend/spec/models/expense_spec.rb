require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expense = build(:expense)
      expect(expense).to be_valid
    end

    it 'is not valid without expense_date' do
      expense = build(:expense, expense_date: nil)
      expect(expense).not_to be_valid
    end

    it 'is not valid without amount' do
      expense = build(:expense, amount: nil)
      expect(expense).not_to be_valid
    end

    it 'is not valid with negative amount' do
      expense = build(:expense, amount: -100)
      expect(expense).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe '#cost_type' do
    it 'returns "cogs" for beer category' do
      expense = build(:expense, category: "beer")
      expect(expense.cost_type).to eq('cogs')
    end

    it 'returns "cogs" for food category' do
      expense = build(:expense, category: "food")
      expect(expense.cost_type).to eq('cogs')
    end

    it 'returns "fixed" for rent category' do
      expense = build(:expense, category: "rent")
      expect(expense.cost_type).to eq('fixed')
    end

    it 'returns "fixed" for payroll category' do
      expense = build(:expense, :payroll)
      expect(expense.cost_type).to eq('fixed')
    end

    it 'returns "variable" for maintenance category' do
      expense = build(:expense, category: "maintenance")
      expect(expense.cost_type).to eq('variable')
    end
  end

  describe 'scopes' do
    let!(:expense1) { create(:expense, payment_source: "daniel_card") }
    let!(:expense2) { create(:expense, payment_source: "cash_petty") }
    let!(:expense3) { create(:expense, payment_source: "daniel_card") }

    before do
      expense3.update!(reimbursed: true)
    end

    it 'finds pending reimbursements' do
      pending = Expense.pending_reimbursement

      expect(pending).to include(expense1)
      expect(pending).not_to include(expense2, expense3)
    end

    it 'filters by date range' do
      expense_jan = create(:expense, expense_date: Date.new(2025, 1, 15))
      expense_feb = create(:expense, expense_date: Date.new(2025, 2, 15))

      expenses = Expense.by_date_range(Date.new(2025, 1, 1), Date.new(2025, 1, 31))

      expect(expenses).to include(expense_jan)
      expect(expenses).not_to include(expense_feb)
    end
  end

  describe 'reimbursement detection' do
    it 'sets requires_reimbursement to true for personal card payments' do
      expense = create(:expense, payment_source: "daniel_card")
      expect(expense.requires_reimbursement).to be true
    end

    it 'sets requires_reimbursement to false for business payments' do
      expense = create(:expense, payment_source: "cash_petty")
      expect(expense.requires_reimbursement).to be false
    end
  end
end
