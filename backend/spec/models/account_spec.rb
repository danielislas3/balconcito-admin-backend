require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      account = build(:account)
      expect(account).to be_valid
    end

    it 'is not valid without a name' do
      account = build(:account, name: nil)
      expect(account).not_to be_valid
    end

    it 'is not valid without an account_type' do
      account = build(:account, account_type: nil)
      expect(account).not_to be_valid
    end

    it 'is not valid with a negative balance' do
      account = build(:account, current_balance: -100)
      expect(account).not_to be_valid
    end

    it 'is valid with zero balance' do
      account = build(:account, current_balance: 0)
      expect(account).to be_valid
    end
  end

  describe 'account types' do
    it 'accepts digital type' do
      account = build(:account, account_type: 'digital')
      expect(account).to be_valid
    end

    it 'accepts physical_cash type' do
      account = build(:account, :boveda)
      expect(account).to be_valid
      expect(account.account_type).to eq('physical_cash')
    end

    it 'accepts petty_cash type' do
      account = build(:account, :caja_chica)
      expect(account).to be_valid
      expect(account.account_type).to eq('petty_cash')
    end
  end

  describe 'scopes' do
    it 'calculates total balance across all accounts' do
      create(:account, current_balance: 1000)
      create(:account, :boveda, current_balance: 2000)
      create(:account, :caja_chica, current_balance: 500)

      expect(Account.total_balance).to eq(3500)
    end
  end
end
