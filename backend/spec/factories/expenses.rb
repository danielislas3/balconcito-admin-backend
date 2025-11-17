FactoryBot.define do
  factory :expense do
    expense_date { Date.today }
    amount { 500.00 }
    description { "Compra de insumos para el bar" }
    category { "beer" }
    payment_source { "cash_petty" }
    provider { "Proveedor de Bebidas SA" }
    receipt_photo_url { nil }
    requires_reimbursement { false }
    reimbursed { false }
    association :user

    trait :cogs do
      category { "beer" }
      payment_source { "cash_petty" }
    end

    trait :payroll do
      category { "payroll" }
      amount { 3000.00 }
      description { "Pago de nómina semanal" }
    end

    trait :pending_reimbursement do
      payment_source { "daniel_card" }
      requires_reimbursement { true }
      reimbursed { false }
    end
  end
end
