FactoryBot.define do
  factory :payment_method do
    association :user
    sequence(:name) { |n| "Payment Method #{n}" }
    payment_type { "business_cash" }
    requires_reimbursement { false }
    is_active { true }
    description { "Método de pago de prueba" }

    trait :business_cash do
      sequence(:name) { |n| "Caja Chica #{n}" }
      payment_type { "business_cash" }
      requires_reimbursement { false }
    end

    trait :business_transfer do
      sequence(:name) { |n| "Transferencia #{n}" }
      payment_type { "business_transfer" }
      requires_reimbursement { false }
    end

    trait :business_card do
      sequence(:name) { |n| "Tarjeta Negocio #{n}" }
      payment_type { "business_card" }
      requires_reimbursement { false }
    end

    trait :personal_card do
      sequence(:name) { |n| "Tarjeta Personal #{n}" }
      payment_type { "personal_card" }
      requires_reimbursement { true }
    end

    trait :personal_cash do
      sequence(:name) { |n| "Efectivo Personal #{n}" }
      payment_type { "personal_cash" }
      requires_reimbursement { true }
    end

    trait :other do
      sequence(:name) { |n| "Otro Método #{n}" }
      payment_type { "other" }
      requires_reimbursement { false }
    end

    trait :inactive do
      is_active { false }
    end
  end
end
