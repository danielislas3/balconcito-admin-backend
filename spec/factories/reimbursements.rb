FactoryBot.define do
  factory :reimbursement do
    reimbursement_date { Date.today }
    amount { 500.00 }
    notes { "Reembolso de gastos de tarjeta personal" }
    association :created_by, factory: :user
    association :to_user, factory: :user
    association :from_account, factory: :account
  end
end
