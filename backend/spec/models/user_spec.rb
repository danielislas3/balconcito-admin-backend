require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is not valid without a name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'validates role inclusion' do
      user = build(:user)
      expect(user).to be_valid
      expect(['admin', 'manager', 'employee']).to include(user.role)
    end

    it 'is valid with admin role' do
      user = build(:user, role: 'admin')
      expect(user).to be_valid
    end

    it 'is valid with manager role' do
      user = build(:user, :manager)
      expect(user).to be_valid
    end

    it 'is valid with employee role' do
      user = build(:user, :employee)
      expect(user).to be_valid
    end
  end

  describe 'associations' do
    it 'has many turn_closures' do
      association = described_class.reflect_on_association(:turn_closures)
      expect(association.macro).to eq :has_many
    end

    it 'has many expenses' do
      association = described_class.reflect_on_association(:expenses)
      expect(association.macro).to eq :has_many
    end
  end
end
