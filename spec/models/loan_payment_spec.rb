require 'rails_helper'

RSpec.describe LoanPayment, type: :model do
  let(:lender) { create(:lender) }
  let(:loan) { create(:loan, lender: lender) }

  describe 'associations' do
    it { should belong_to(:loan) }
  end

  describe 'validations' do
    subject { build(:loan_payment, loan: loan) }

    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:payment_date) }
    it { should validate_presence_of(:payment_number) }

    it 'validates amount is greater than 0' do
      payment = build(:loan_payment, amount: 0)
      expect(payment).not_to be_valid

      payment.amount = 100
      expect(payment).to be_valid
    end

    it 'validates payment_number uniqueness per loan' do
      create(:loan_payment, loan: loan, payment_number: 1)
      payment2 = build(:loan_payment, loan: loan, payment_number: 1)

      expect(payment2).not_to be_valid
      expect(payment2.errors[:payment_number]).to include('ya existe para este préstamo')
    end

    it 'allows same payment_number for different loans' do
      loan2 = create(:loan, lender: lender)

      create(:loan_payment, loan: loan, payment_number: 1)
      payment2 = build(:loan_payment, loan: loan2, payment_number: 1)

      expect(payment2).to be_valid
    end
  end

  describe 'scopes' do
    let!(:payment1) { create(:loan_payment, loan: loan, payment_date: Date.today - 2.days) }
    let!(:payment2) { create(:loan_payment, loan: loan, payment_date: Date.today) }

    describe '.by_date_range' do
      it 'returns payments within date range' do
        payments = LoanPayment.by_date_range(Date.today - 3.days, Date.today)
        expect(payments).to include(payment1, payment2)
      end

      it 'excludes payments outside date range' do
        old_payment = create(:loan_payment, loan: loan, payment_date: Date.today - 10.days)
        payments = LoanPayment.by_date_range(Date.today - 3.days, Date.today)

        expect(payments).not_to include(old_payment)
      end
    end

    describe '.recent' do
      it 'orders payments by payment_date descending' do
        recent = LoanPayment.recent
        expect(recent.first).to eq(payment2)
        expect(recent.last).to eq(payment1)
      end
    end
  end

  describe 'instance methods' do
    describe '#display_info' do
      it 'returns formatted payment information' do
        payment = create(:loan_payment, loan: loan, payment_number: 3, amount: 2500, payment_date: Date.new(2025, 11, 15))
        expect(payment.display_info).to eq('Pago #3 - $2500.0 - 15/11/2025')
      end
    end

    describe '#lender_name' do
      it 'returns the lender name' do
        payment = create(:loan_payment, loan: loan)
        expect(payment.lender_name).to eq(loan.lender.name)
      end
    end
  end
end
