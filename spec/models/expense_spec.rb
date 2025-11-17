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

    it 'belongs to payment_method' do
      association = described_class.reflect_on_association(:payment_method)
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
    let(:user) { create(:user) }
    let(:personal_pm) { create(:payment_method, :personal_card, user: user) }
    let(:business_pm) { create(:payment_method, :business_cash, user: user) }

    let!(:expense1) { create(:expense, user: user, payment_method: personal_pm) }
    let!(:expense2) { create(:expense, user: user, payment_method: business_pm) }
    let!(:expense3) { create(:expense, user: user, payment_method: personal_pm) }

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
    let(:user) { create(:user) }

    it 'sets requires_reimbursement to true for personal card payments' do
      personal_pm = create(:payment_method, :personal_card, user: user)
      expense = create(:expense, user: user, payment_method: personal_pm)
      expect(expense.requires_reimbursement).to be true
    end

    it 'sets requires_reimbursement to false for business payments' do
      business_pm = create(:payment_method, :business_cash, user: user)
      expense = create(:expense, user: user, payment_method: business_pm)
      expect(expense.requires_reimbursement).to be false
    end

    it 'sets requires_reimbursement to false when no payment_method' do
      expense = create(:expense, user: user, payment_method: nil)
      expect(expense.requires_reimbursement).to be false
    end
  end

  describe 'instance methods' do
    let(:user) { create(:user) }

    describe '#payment_source_name' do
      it 'returns payment method name when present' do
        pm = create(:payment_method, :business_cash, user: user, name: 'Caja Chica')
        expense = create(:expense, user: user, payment_method: pm)
        expect(expense.payment_source_name).to eq('Caja Chica')
      end

      it 'returns "No especificado" when payment_method is nil' do
        expense = create(:expense, user: user, payment_method: nil)
        expect(expense.payment_source_name).to eq('No especificado')
      end
    end

    describe '#paid_by_user' do
      it 'returns payment method user when present' do
        pm_user = create(:user, name: 'Daniel', email: 'daniel@test.com')
        pm = create(:payment_method, :personal_card, user: pm_user)
        expense = create(:expense, user: user, payment_method: pm)
        expect(expense.paid_by_user).to eq(pm_user)
      end

      it 'returns expense user when payment_method is nil' do
        expense = create(:expense, user: user, payment_method: nil)
        expect(expense.paid_by_user).to eq(user)
      end
    end
  end
end
