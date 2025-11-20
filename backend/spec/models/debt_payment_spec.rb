require 'rails_helper'

RSpec.describe DebtPayment, type: :model do
  let(:user) { create(:user) }
  let(:credit_card) { create(:credit_card, user: user) }
  let(:credit_purchase) { create(:credit_purchase, credit_card: credit_card, user: user) }

  describe 'associations' do
    it { should belong_to(:credit_purchase) }
  end

  describe 'validations' do
    subject { build(:debt_payment, credit_purchase: credit_purchase) }

    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:payment_date) }
    it { should validate_presence_of(:payment_number) }

    it 'validates amount is greater than 0' do
      payment = build(:debt_payment, amount: 0)
      expect(payment).not_to be_valid

      payment.amount = 100
      expect(payment).to be_valid
    end

    it 'validates payment_number uniqueness per credit_purchase' do
      create(:debt_payment, credit_purchase: credit_purchase, payment_number: 1)
      payment2 = build(:debt_payment, credit_purchase: credit_purchase, payment_number: 1)

      expect(payment2).not_to be_valid
      expect(payment2.errors[:payment_number]).to include('ya existe para esta compra')
    end

    it 'allows same payment_number for different purchases' do
      purchase2 = create(:credit_purchase, credit_card: credit_card, user: user)

      create(:debt_payment, credit_purchase: credit_purchase, payment_number: 1)
      payment2 = build(:debt_payment, credit_purchase: purchase2, payment_number: 1)

      expect(payment2).to be_valid
    end
  end

  describe 'scopes' do
    let!(:payment1) { create(:debt_payment, credit_purchase: credit_purchase, payment_date: Date.today - 2.days) }
    let!(:payment2) { create(:debt_payment, credit_purchase: credit_purchase, payment_date: Date.today) }

    describe '.by_date_range' do
      it 'returns payments within date range' do
        payments = DebtPayment.by_date_range(Date.today - 3.days, Date.today)
        expect(payments).to include(payment1, payment2)
      end

      it 'excludes payments outside date range' do
        old_payment = create(:debt_payment, credit_purchase: credit_purchase, payment_date: Date.today - 10.days)
        payments = DebtPayment.by_date_range(Date.today - 3.days, Date.today)

        expect(payments).not_to include(old_payment)
      end
    end

    describe '.recent' do
      it 'orders payments by payment_date descending' do
        recent = DebtPayment.recent
        expect(recent.first).to eq(payment2)
        expect(recent.last).to eq(payment1)
      end
    end
  end

  describe 'instance methods' do
    describe '#display_info' do
      it 'returns formatted payment information' do
        payment = create(:debt_payment, payment_number: 5, amount: 1500, payment_date: Date.new(2025, 11, 15))
        expect(payment.display_info).to eq('Pago #5 - 1500.0 - 15/11/2025')
      end
    end
  end
end
