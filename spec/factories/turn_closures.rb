FactoryBot.define do
  factory :turn_closure do
    sequence(:closure_number) { |n| n }
    report_date { Date.today }
    cash_collected { 1500.00 }
    transfer_income { 800.00 }
    card_income { 600.00 }
    closed_by { "Daniel" }
    theoretical_cash { 1500.00 }
    payments_withdrawals { 200.00 }
    notes { "Cierre de turno normal" }
    association :user
  end
end
