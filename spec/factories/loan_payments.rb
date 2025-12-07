FactoryBot.define do
  factory :loan_payment do
    association :loan
    amount { 2500.00 }
    payment_date { Date.today }
    sequence(:payment_number) { |n| n }
    notes { "Pago mensual" }
  end
end
