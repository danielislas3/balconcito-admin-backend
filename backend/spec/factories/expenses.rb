FactoryBot.define do
  factory :expense do
    expense_date { Date.today }
    amount { 500.00 }
    description { "Compra de insumos para el bar" }
    category { "beer" }
    provider { "Proveedor de Bebidas SA" }
    receipt_photo_url { nil }
    requires_reimbursement { false }
    reimbursed { false }
    association :user
    association :payment_method

    trait :cogs do
      category { "beer" }
      after(:build) do |expense|
        expense.payment_method = create(:payment_method, :business_cash, user: expense.user)
      end
    end

    trait :payroll do
      category { "payroll" }
      amount { 3000.00 }
      description { "Pago de nómina semanal" }
      after(:build) do |expense|
        expense.payment_method = create(:payment_method, :business_transfer, user: expense.user)
      end
    end

    trait :pending_reimbursement do
      requires_reimbursement { true }
      reimbursed { false }
      after(:build) do |expense|
        expense.payment_method = create(:payment_method, :personal_card, user: expense.user)
      end
    end
  end
end
