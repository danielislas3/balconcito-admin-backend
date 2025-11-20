FactoryBot.define do
  factory :loan do
    association :lender
    principal_amount { 30000.00 }
    interest_rate { 0 }
    term_months { 12 }
    loan_date { Date.today - 1.month }
    remaining_balance { 30000.00 }
    is_paid { false }
    notes { "Préstamo de prueba" }

    trait :with_interest do
      interest_rate { 10.0 }
    end

    trait :short_term do
      term_months { 6 }
      principal_amount { 10000.00 }
      remaining_balance { 10000.00 }
    end

    trait :long_term do
      term_months { 24 }
      principal_amount { 100000.00 }
      remaining_balance { 100000.00 }
    end

    trait :partially_paid do
      remaining_balance { 15000.00 }
    end

    trait :almost_paid do
      remaining_balance { 2000.00 }
    end

    trait :paid do
      remaining_balance { 0 }
      is_paid { true }
    end
  end
end
