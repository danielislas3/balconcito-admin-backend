require 'rails_helper'

RSpec.describe CreditPurchase, type: :model do
  let(:user) { create(:user) }
  let(:credit_card) { create(:credit_card, user: user) }

  describe 'associations' do
    it { should belong_to(:credit_card) }
    it { should belong_to(:user) }
    it { should have_many(:debt_payments).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:credit_purchase, credit_card: credit_card, user: user) }

    it { should validate_presence_of(:concept) }
    it { should validate_presence_of(:total_amount) }
    it { should validate_presence_of(:monthly_payment) }
    it { should validate_presence_of(:total_months) }
    it { should validate_presence_of(:purchase_date) }

    it 'validates total_amount is greater than 0' do
      purchase = build(:credit_purchase, total_amount: 0)
      expect(purchase).not_to be_valid

      purchase.total_amount = 1000
      expect(purchase).to be_valid
    end

    it 'validates monthly_payment is greater than 0' do
      purchase = build(:credit_purchase, monthly_payment: 0)
      expect(purchase).not_to be_valid

      purchase.monthly_payment = 100
      expect(purchase).to be_valid
    end
  end

  describe 'callbacks' do
    it 'sets initial remaining_balance to total_amount on create' do
      purchase = create(:credit_purchase, total_amount: 5000, remaining_balance: nil)
      expect(purchase.remaining_balance).to eq(5000)
    end

    it 'initializes paid_months to 0' do
      purchase = create(:credit_purchase)
      expect(purchase.paid_months).to eq(0)
    end

    it 'initializes fully_paid to false' do
      purchase = create(:credit_purchase)
      expect(purchase.fully_paid).to be false
    end
  end

  describe 'scopes' do
    let!(:active_purchase) { create(:credit_purchase, credit_card: credit_card, user: user, fully_paid: false) }
    let!(:paid_purchase) { create(:credit_purchase, credit_card: credit_card, user: user, fully_paid: true) }

    describe '.active' do
      it 'returns only unpaid purchases' do
        active = CreditPurchase.active
        expect(active).to include(active_purchase)
        expect(active).not_to include(paid_purchase)
      end
    end

    describe '.fully_paid' do
      it 'returns only paid purchases' do
        paid = CreditPurchase.fully_paid
        expect(paid).to include(paid_purchase)
        expect(paid).not_to include(active_purchase)
      end
    end
  end

  describe 'instance methods' do
    describe '#remaining_months' do
      it 'returns total_months minus paid_months' do
        purchase = create(:credit_purchase, total_months: 12, paid_months: 5)
        expect(purchase.remaining_months).to eq(7)
      end
    end

    describe '#progress_percentage' do
      it 'returns 0 when no payments made' do
        purchase = create(:credit_purchase, total_months: 12, paid_months: 0)
        expect(purchase.progress_percentage).to eq(0.0)
      end

      it 'returns 50% when half paid' do
        purchase = create(:credit_purchase, total_months: 12, paid_months: 6)
        expect(purchase.progress_percentage).to eq(50.0)
      end

      it 'returns 100% when fully paid' do
        purchase = create(:credit_purchase, total_months: 12, paid_months: 12)
        expect(purchase.progress_percentage).to eq(100.0)
      end
    end

    describe '#mark_as_paid!' do
      it 'marks purchase as fully paid' do
        purchase = create(:credit_purchase, :partially_paid)
        purchase.mark_as_paid!

        expect(purchase.fully_paid).to be true
        expect(purchase.remaining_balance).to eq(0)
        expect(purchase.paid_months).to eq(purchase.total_months)
      end
    end

    describe '#record_payment' do
      let(:purchase) { create(:credit_purchase, total_amount: 12000, monthly_payment: 1000, total_months: 12, remaining_balance: 12000, paid_months: 0) }

      it 'creates a debt payment record' do
        expect {
          purchase.record_payment(1000, Date.today)
        }.to change(DebtPayment, :count).by(1)
      end

      it 'updates remaining_balance' do
        purchase.record_payment(1000, Date.today)
        expect(purchase.remaining_balance).to eq(11000)
      end

      it 'increments paid_months' do
        purchase.record_payment(1000, Date.today)
        expect(purchase.paid_months).to eq(1)
      end

      it 'marks as fully_paid when last payment is made' do
        purchase.update(paid_months: 11, remaining_balance: 1000)
        purchase.record_payment(1000, Date.today)

        expect(purchase.fully_paid).to be true
        expect(purchase.remaining_balance).to eq(0)
      end

      it 'does not allow payment when already fully paid' do
        purchase.update(fully_paid: true)
        result = purchase.record_payment(1000, Date.today)

        expect(result).to be false
      end

      it 'prevents negative remaining_balance' do
        purchase.update(remaining_balance: 500)
        purchase.record_payment(1000, Date.today)

        expect(purchase.remaining_balance).to eq(0)
      end
    end
  end
end
