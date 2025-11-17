require 'rails_helper'

RSpec.describe Loan, type: :model do
  let(:lender) { create(:lender) }

  describe 'associations' do
    it { should belong_to(:lender) }
    it { should have_many(:loan_payments).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:principal_amount) }
    it { should validate_presence_of(:interest_rate) }
    it { should validate_presence_of(:term_months) }
    it { should validate_presence_of(:loan_date) }

    it 'validates principal_amount is greater than 0' do
      loan = build(:loan, principal_amount: 0)
      expect(loan).not_to be_valid

      loan.principal_amount = 1000
      expect(loan).to be_valid
    end

    it 'validates interest_rate is greater than or equal to 0' do
      loan = build(:loan, interest_rate: -1)
      expect(loan).not_to be_valid

      loan.interest_rate = 0
      expect(loan).to be_valid

      loan.interest_rate = 10
      expect(loan).to be_valid
    end
  end

  describe 'callbacks' do
    it 'sets initial remaining_balance to principal_amount on create' do
      loan = create(:loan, principal_amount: 50000, remaining_balance: nil)
      expect(loan.remaining_balance).to eq(50000)
    end

    it 'calculates due_date based on loan_date and term_months' do
      loan = create(:loan, loan_date: Date.new(2025, 1, 1), term_months: 12, due_date: nil)
      expect(loan.due_date).to eq(Date.new(2026, 1, 1))
    end

    it 'initializes is_paid to false' do
      loan = create(:loan)
      expect(loan.is_paid).to be false
    end
  end

  describe 'scopes' do
    let!(:active_loan) { create(:loan, lender: lender, is_paid: false) }
    let!(:paid_loan) { create(:loan, lender: lender, is_paid: true) }
    let!(:interest_loan) { create(:loan, :with_interest, lender: lender) }
    let!(:interest_free_loan) { create(:loan, lender: lender, interest_rate: 0) }

    describe '.active' do
      it 'returns only unpaid loans' do
        active = Loan.active
        expect(active).to include(active_loan, interest_loan, interest_free_loan)
        expect(active).not_to include(paid_loan)
      end
    end

    describe '.paid' do
      it 'returns only paid loans' do
        paid = Loan.paid
        expect(paid).to include(paid_loan)
        expect(paid).not_to include(active_loan)
      end
    end

    describe '.with_interest' do
      it 'returns loans with interest rate > 0' do
        with_interest = Loan.with_interest
        expect(with_interest).to include(interest_loan)
        expect(with_interest).not_to include(interest_free_loan)
      end
    end

    describe '.interest_free' do
      it 'returns loans with 0% interest' do
        interest_free = Loan.interest_free
        expect(interest_free).to include(interest_free_loan, active_loan)
        expect(interest_free).not_to include(interest_loan)
      end
    end
  end

  describe 'instance methods' do
    describe '#monthly_payment' do
      it 'calculates correctly for interest-free loan' do
        loan = create(:loan, principal_amount: 30000, term_months: 12, interest_rate: 0)
        expect(loan.monthly_payment).to eq(2500.00)
      end

      it 'calculates correctly for loan with interest' do
        loan = create(:loan, principal_amount: 30000, term_months: 12, interest_rate: 10)
        # Formula de amortización: debe ser aproximadamente $2,641
        expect(loan.monthly_payment).to be_within(5).of(2641)
      end
    end

    describe '#total_amount_with_interest' do
      it 'returns principal_amount for interest-free loan' do
        loan = create(:loan, principal_amount: 30000, interest_rate: 0)
        expect(loan.total_amount_with_interest).to eq(30000)
      end

      it 'calculates total with interest' do
        loan = create(:loan, principal_amount: 30000, term_months: 12, interest_rate: 10)
        total = loan.monthly_payment * 12
        expect(loan.total_amount_with_interest).to eq(total)
      end
    end

    describe '#total_interest' do
      it 'returns 0 for interest-free loan' do
        loan = create(:loan, principal_amount: 30000, interest_rate: 0)
        expect(loan.total_interest).to eq(0)
      end

      it 'calculates total interest paid' do
        loan = create(:loan, principal_amount: 30000, term_months: 12, interest_rate: 10)
        expect(loan.total_interest).to be > 0
      end
    end

    describe '#progress_percentage' do
      it 'returns 0 when no payments made' do
        loan = create(:loan, principal_amount: 30000, remaining_balance: 30000)
        expect(loan.progress_percentage).to eq(0.0)
      end

      it 'returns 50% when half paid' do
        loan = create(:loan, principal_amount: 30000, remaining_balance: 15000)
        expect(loan.progress_percentage).to eq(50.0)
      end

      it 'returns 100% when fully paid' do
        loan = create(:loan, principal_amount: 30000, remaining_balance: 0)
        expect(loan.progress_percentage).to eq(100.0)
      end
    end

    describe '#payments_made_count' do
      it 'returns count of loan payments' do
        loan = create(:loan)
        create(:loan_payment, loan: loan, payment_number: 1)
        create(:loan_payment, loan: loan, payment_number: 2)

        expect(loan.payments_made_count).to eq(2)
      end
    end

    describe '#payments_remaining' do
      it 'returns remaining payments' do
        loan = create(:loan, term_months: 12)
        create(:loan_payment, loan: loan, payment_number: 1)
        create(:loan_payment, loan: loan, payment_number: 2)

        expect(loan.payments_remaining).to eq(10)
      end
    end

    describe '#mark_as_paid!' do
      it 'marks loan as fully paid' do
        loan = create(:loan, :partially_paid)
        loan.mark_as_paid!

        expect(loan.is_paid).to be true
        expect(loan.remaining_balance).to eq(0)
      end
    end

    describe '#record_payment' do
      let(:loan) { create(:loan, principal_amount: 30000, remaining_balance: 30000, is_paid: false) }

      it 'creates a loan payment record' do
        expect {
          loan.record_payment(2500, Date.today)
        }.to change(LoanPayment, :count).by(1)
      end

      it 'updates remaining_balance' do
        loan.record_payment(2500, Date.today)
        expect(loan.remaining_balance).to eq(27500)
      end

      it 'marks as paid when last payment is made' do
        loan.update(remaining_balance: 2500)
        loan.record_payment(2500, Date.today)

        expect(loan.is_paid).to be true
        expect(loan.remaining_balance).to eq(0)
      end

      it 'does not allow payment when already paid' do
        loan.update(is_paid: true)
        result = loan.record_payment(1000, Date.today)

        expect(result).to be false
      end
    end

    describe '#is_overdue?' do
      it 'returns false when loan is paid' do
        loan = create(:loan, :paid, due_date: Date.today - 10.days)
        expect(loan.is_overdue?).to be false
      end

      it 'returns true when past due date' do
        loan = create(:loan, due_date: Date.today - 1.day, is_paid: false)
        expect(loan.is_overdue?).to be true
      end

      it 'returns false when not yet due' do
        loan = create(:loan, due_date: Date.today + 30.days, is_paid: false)
        expect(loan.is_overdue?).to be false
      end
    end

    describe '#days_until_due' do
      it 'returns 0 when paid' do
        loan = create(:loan, :paid)
        expect(loan.days_until_due).to eq(0)
      end

      it 'returns days remaining' do
        loan = create(:loan, due_date: Date.today + 30.days, is_paid: false)
        expect(loan.days_until_due).to eq(30)
      end

      it 'returns negative days when overdue' do
        loan = create(:loan, due_date: Date.today - 10.days, is_paid: false)
        expect(loan.days_until_due).to eq(-10)
      end
    end
  end
end
