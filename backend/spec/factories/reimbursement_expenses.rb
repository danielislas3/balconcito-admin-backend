FactoryBot.define do
  factory :reimbursement_expense do
    reimbursement { nil }
    expense { nil }
    amount { "9.99" }
  end
end
