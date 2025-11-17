require 'rails_helper'

RSpec.describe CreditCard, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:credit_purchases).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { build(:credit_card, user: user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:bank_name) }
    it { should validate_presence_of(:cut_day) }

    context 'uniqueness of name scoped to user' do
      it 'allows same name for different users' do
        user1 = create(:user, email: 'user1@test.com')
        user2 = create(:user, email: 'user2@test.com')

        create(:credit_card, user: user1, name: 'Visa')
        card2 = build(:credit_card, user: user2, name: 'Visa')

        expect(card2).to be_valid
      end

      it 'does not allow same name for same user' do
        create(:credit_card, user: user, name: 'Visa')
        card2 = build(:credit_card, user: user, name: 'Visa')

        expect(card2).not_to be_valid
        expect(card2.errors[:name]).to include('ya existe para este usuario')
      end
    end

    it 'validates cut_day is between 1 and 31' do
      card = build(:credit_card, cut_day: 0)
      expect(card).not_to be_valid

      card.cut_day = 32
      expect(card).not_to be_valid

      card.cut_day = 15
      expect(card).to be_valid
    end
  end

  describe 'scopes' do
    let!(:active_card) { create(:credit_card, user: user) }
    let!(:inactive_card) { create(:credit_card, :inactive, user: user) }
    let!(:other_user_card) { create(:credit_card, user: create(:user, email: 'other@test.com')) }

    describe '.active' do
      it 'returns only active cards' do
        active = CreditCard.active
        expect(active).to include(active_card, other_user_card)
        expect(active).not_to include(inactive_card)
      end
    end

    describe '.for_user' do
      it 'returns cards for specific user' do
        user_cards = CreditCard.for_user(user.id)
        expect(user_cards).to include(active_card, inactive_card)
        expect(user_cards).not_to include(other_user_card)
      end
    end
  end

  describe 'instance methods' do
    let(:card) { create(:credit_card, user: user, credit_limit: 50000) }

    describe '#total_debt' do
      it 'returns 0 when no purchases' do
        expect(card.total_debt).to eq(0)
      end

      it 'returns sum of remaining balances from unpaid purchases' do
        create(:credit_purchase, credit_card: card, user: user, remaining_balance: 10000, fully_paid: false)
        create(:credit_purchase, credit_card: card, user: user, remaining_balance: 5000, fully_paid: false)
        create(:credit_purchase, credit_card: card, user: user, remaining_balance: 0, fully_paid: true)

        expect(card.total_debt).to eq(15000)
      end
    end

    describe '#monthly_commitment' do
      it 'returns 0 when no active purchases' do
        expect(card.monthly_commitment).to eq(0)
      end

      it 'returns sum of monthly payments from unpaid purchases' do
        create(:credit_purchase, credit_card: card, user: user, monthly_payment: 1000, fully_paid: false)
        create(:credit_purchase, credit_card: card, user: user, monthly_payment: 500, fully_paid: false)
        create(:credit_purchase, credit_card: card, user: user, monthly_payment: 300, fully_paid: true)

        expect(card.monthly_commitment).to eq(1500)
      end
    end

    describe '#available_credit' do
      it 'returns 0 when credit_limit is 0' do
        card.update(credit_limit: 0)
        expect(card.available_credit).to eq(0)
      end

      it 'returns credit_limit minus total_debt' do
        create(:credit_purchase, credit_card: card, user: user, remaining_balance: 15000, fully_paid: false)
        expect(card.available_credit).to eq(35000)
      end
    end

    describe '#credit_utilization_percentage' do
      it 'returns 0 when credit_limit is 0' do
        card.update(credit_limit: 0)
        expect(card.credit_utilization_percentage).to eq(0)
      end

      it 'calculates percentage correctly' do
        create(:credit_purchase, credit_card: card, user: user, remaining_balance: 25000, fully_paid: false)
        expect(card.credit_utilization_percentage).to eq(50.0)
      end
    end

    describe '#display_name' do
      it 'returns formatted name with bank' do
        card.update(name: 'Visa Oro', bank_name: 'Banamex')
        expect(card.display_name).to eq('Visa Oro - Banamex')
      end
    end

    describe '#active_purchases_count' do
      it 'returns count of unpaid purchases' do
        create(:credit_purchase, credit_card: card, user: user, fully_paid: false)
        create(:credit_purchase, credit_card: card, user: user, fully_paid: false)
        create(:credit_purchase, credit_card: card, user: user, fully_paid: true)

        expect(card.active_purchases_count).to eq(2)
      end
    end
  end
end
