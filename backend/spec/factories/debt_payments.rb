FactoryBot.define do
  factory :debt_payment do
    association :credit_purchase
    amount { 1000.00 }
    payment_date { Date.today }
    sequence(:payment_number) { |n| n }
    notes { "Pago mensual" }
  end
end
