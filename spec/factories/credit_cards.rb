FactoryBot.define do
  factory :credit_card do
    association :user
    sequence(:name) { |n| "Tarjeta #{n}" }
    bank_name { "Banco Test" }
    cut_day { 15 }
    credit_limit { 50000.00 }
    statement_day { 20 }
    is_active { true }
    notes { "Tarjeta de crédito de prueba" }

    trait :banamex do
      sequence(:name) { |n| "Banamex #{n}" }
      bank_name { "Banamex" }
      cut_day { 12 }
      credit_limit { 100000.00 }
    end

    trait :bancomer do
      sequence(:name) { |n| "Bancomer #{n}" }
      bank_name { "Bancomer" }
      cut_day { 21 }
      credit_limit { 80000.00 }
    end

    trait :inactive do
      is_active { false }
    end

    trait :no_limit do
      credit_limit { 0 }
    end
  end
end
