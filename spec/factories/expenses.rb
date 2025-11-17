FactoryBot.define do
  factory :expense do
    expense_date { "2025-11-17" }
    amount { "9.99" }
    description { "MyText" }
    category { "MyString" }
    payment_source { "MyString" }
    provider { "MyString" }
    receipt_photo_url { "MyString" }
    requires_reimbursement { false }
    reimbursed { false }
    user { nil }
  end
end
