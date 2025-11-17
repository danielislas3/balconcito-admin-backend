FactoryBot.define do
  factory :reimbursement do
    reimbursement_date { "2025-11-17" }
    amount { "9.99" }
    notes { "MyText" }
    user { nil }
  end
end
