require 'rails_helper'

RSpec.describe Lender, type: :model do
  describe 'associations' do
    it { should have_many(:loans).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:relationship) }
  end

  describe 'scopes' do
    let!(:active_investor) { create(:lender, :investor) }
    let!(:inactive_investor) { create(:lender, :investor, :inactive) }
    let!(:family_lender) { create(:lender, :family) }
    let!(:friend_lender) { create(:lender, :friend) }

    describe '.active' do
      it 'returns only active lenders' do
        active = Lender.active
        expect(active).to include(active_investor, family_lender, friend_lender)
        expect(active).not_to include(inactive_investor)
      end
    end

    describe '.investors' do
      it 'returns only investors' do
        investors = Lender.investors
        expect(investors).to include(active_investor, inactive_investor)
        expect(investors).not_to include(family_lender, friend_lender)
      end
    end

    describe '.family' do
      it 'returns only family members' do
        family = Lender.family
        expect(family).to include(family_lender)
        expect(family).not_to include(active_investor, friend_lender)
      end
    end

    describe '.friends' do
      it 'returns only friends' do
        friends = Lender.friends
        expect(friends).to include(friend_lender)
        expect(friends).not_to include(active_investor, family_lender)
      end
    end
  end

  describe 'instance methods' do
    let(:lender) { create(:lender) }

    describe '#total_lent' do
      it 'returns 0 when no loans' do
        expect(lender.total_lent).to eq(0)
      end

      it 'returns sum of all loan principal amounts' do
        create(:loan, lender: lender, principal_amount: 10000)
        create(:loan, lender: lender, principal_amount: 20000)
        create(:loan, lender: lender, principal_amount: 15000, is_paid: true)

        expect(lender.total_lent).to eq(45000)
      end
    end

    describe '#total_outstanding' do
      it 'returns 0 when no unpaid loans' do
        create(:loan, lender: lender, is_paid: true, remaining_balance: 0)
        expect(lender.total_outstanding).to eq(0)
      end

      it 'returns sum of remaining balances from unpaid loans' do
        create(:loan, lender: lender, remaining_balance: 10000, is_paid: false)
        create(:loan, lender: lender, remaining_balance: 5000, is_paid: false)
        create(:loan, lender: lender, remaining_balance: 0, is_paid: true)

        expect(lender.total_outstanding).to eq(15000)
      end
    end

    describe '#total_paid' do
      it 'returns 0 when no paid loans' do
        create(:loan, lender: lender, is_paid: false)
        expect(lender.total_paid).to eq(0)
      end

      it 'returns sum of principal from paid loans' do
        create(:loan, lender: lender, principal_amount: 10000, is_paid: true)
        create(:loan, lender: lender, principal_amount: 5000, is_paid: true)
        create(:loan, lender: lender, principal_amount: 8000, is_paid: false)

        expect(lender.total_paid).to eq(15000)
      end
    end

    describe '#active_loans_count' do
      it 'returns count of unpaid loans' do
        create(:loan, lender: lender, is_paid: false)
        create(:loan, lender: lender, is_paid: false)
        create(:loan, lender: lender, is_paid: true)

        expect(lender.active_loans_count).to eq(2)
      end
    end

    describe '#display_name' do
      it 'returns formatted name with relationship' do
        lender.update(name: 'Juan Pérez', relationship: 'inversionista')
        expect(lender.display_name).to eq('Juan Pérez (Inversionista)')
      end
    end

    describe '#contact_info' do
      it 'returns combined contact information' do
        lender.update(contact_email: 'juan@email.com', contact_phone: '555-1234')
        expect(lender.contact_info).to eq('juan@email.com / 555-1234')
      end

      it 'returns only email when no phone' do
        lender.update(contact_email: 'juan@email.com', contact_phone: nil)
        expect(lender.contact_info).to eq('juan@email.com')
      end
    end
  end
end
