require 'rails_helper'

RSpec.describe PaymentMethod, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:expenses).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { build(:payment_method, user: user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:payment_type) }

    context 'uniqueness of name scoped to user' do
      it 'allows same name for different users' do
        user1 = create(:user, email: 'user1@test.com')
        user2 = create(:user, email: 'user2@test.com')

        create(:payment_method, user: user1, name: 'Tarjeta')
        pm2 = build(:payment_method, user: user2, name: 'Tarjeta')

        expect(pm2).to be_valid
      end

      it 'does not allow same name for same user' do
        create(:payment_method, user: user, name: 'Tarjeta')
        pm2 = build(:payment_method, user: user, name: 'Tarjeta')

        expect(pm2).not_to be_valid
        expect(pm2.errors[:name]).to include('ya existe para este usuario')
      end
    end
  end

  describe 'enums' do
    it 'defines payment_type enum' do
      expect(PaymentMethod.payment_types.keys).to include(
        'business_cash', 'business_transfer', 'business_card',
        'personal_card', 'personal_cash', 'other'
      )
    end

    it 'creates a payment_method with business_cash type' do
      pm = create(:payment_method, :business_cash, user: user)
      expect(pm.business_cash?).to be true
    end

    it 'creates a payment_method with personal_card type' do
      pm = create(:payment_method, :personal_card, user: user)
      expect(pm.personal_card?).to be true
    end
  end

  describe 'scopes' do
    let!(:active_business) { create(:payment_method, :business_cash, user: user) }
    let!(:active_personal) { create(:payment_method, :personal_card, user: user) }
    let!(:inactive_personal) { create(:payment_method, :personal_card, :inactive, user: user) }
    let!(:other_user_pm) { create(:payment_method, :business_transfer, user: create(:user, email: 'other@test.com')) }

    describe '.active' do
      it 'returns only active payment methods' do
        active = PaymentMethod.active
        expect(active).to include(active_business, active_personal, other_user_pm)
        expect(active).not_to include(inactive_personal)
      end
    end

    describe '.business_methods' do
      it 'returns only business payment methods' do
        business = PaymentMethod.business_methods
        expect(business).to include(active_business, other_user_pm)
        expect(business).not_to include(active_personal, inactive_personal)
      end
    end

    describe '.personal_methods' do
      it 'returns only personal payment methods' do
        personal = PaymentMethod.personal_methods
        expect(personal).to include(active_personal, inactive_personal)
        expect(personal).not_to include(active_business, other_user_pm)
      end
    end

    describe '.for_user' do
      it 'returns payment methods for specific user' do
        user_methods = PaymentMethod.for_user(user.id)
        expect(user_methods).to include(active_business, active_personal, inactive_personal)
        expect(user_methods).not_to include(other_user_pm)
      end
    end
  end

  describe 'instance methods' do
    describe '#display_name' do
      it 'returns formatted name with payment type' do
        pm = create(:payment_method, :business_cash, user: user, name: 'Caja Chica')
        expect(pm.display_name).to include('Caja Chica')
      end
    end

    describe '#business_owned?' do
      it 'returns true for business_cash' do
        pm = create(:payment_method, :business_cash, user: user)
        expect(pm.business_owned?).to be true
      end

      it 'returns true for business_transfer' do
        pm = create(:payment_method, :business_transfer, user: user)
        expect(pm.business_owned?).to be true
      end

      it 'returns true for business_card' do
        pm = create(:payment_method, :business_card, user: user)
        expect(pm.business_owned?).to be true
      end

      it 'returns false for personal_card' do
        pm = create(:payment_method, :personal_card, user: user)
        expect(pm.business_owned?).to be false
      end
    end

    describe '#personal_owned?' do
      it 'returns true for personal_card' do
        pm = create(:payment_method, :personal_card, user: user)
        expect(pm.personal_owned?).to be true
      end

      it 'returns true for personal_cash' do
        pm = create(:payment_method, :personal_cash, user: user)
        expect(pm.personal_owned?).to be true
      end

      it 'returns false for business_cash' do
        pm = create(:payment_method, :business_cash, user: user)
        expect(pm.personal_owned?).to be false
      end
    end
  end
end
