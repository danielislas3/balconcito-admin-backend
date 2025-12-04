FactoryBot.define do
  factory :credit_purchase do
    association :credit_card
    association :user
    sequence(:concept) { |n| "Compra a MSI #{n}" }
    total_amount { 12000.00 }
    monthly_payment { 1000.00 }
    total_months { 12 }
    purchase_date { Date.today - 2.months }
    remaining_balance { 12000.00 }
    paid_months { 0 }
    fully_paid { false }
    notes { "Compra de prueba a meses sin intereses" }

    trait :partially_paid do
      paid_months { 3 }
      remaining_balance { 9000.00 }
    end

    trait :almost_paid do
      paid_months { 11 }
      remaining_balance { 1000.00 }
    end

    trait :fully_paid do
      paid_months { 12 }
      remaining_balance { 0 }
      fully_paid { true }
    end

    trait :three_months do
      total_months { 3 }
      total_amount { 3000.00 }
      monthly_payment { 1000.00 }
      remaining_balance { 3000.00 }
    end

    trait :six_months do
      total_months { 6 }
      total_amount { 6000.00 }
      monthly_payment { 1000.00 }
      remaining_balance { 6000.00 }
    end

    trait :twelve_months do
      total_months { 12 }
      total_amount { 12000.00 }
      monthly_payment { 1000.00 }
      remaining_balance { 12000.00 }
    end
  end
end
