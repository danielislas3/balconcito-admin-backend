FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "Account #{n}" }
    account_type { "digital" }
    current_balance { 5000.00 }
    description { "Cuenta digital para cobros electrónicos" }

    trait :boveda do
      name { "Bóveda" }
      account_type { "physical_cash" }
      current_balance { 3000.00 }
      description { "Efectivo resguardado en bóveda" }
    end

    trait :caja_chica do
      name { "Caja Chica" }
      account_type { "petty_cash" }
      current_balance { 1000.00 }
      description { "Caja chica para gastos operativos" }
    end
  end
end
