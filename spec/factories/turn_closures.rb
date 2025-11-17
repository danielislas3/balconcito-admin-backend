FactoryBot.define do
  factory :turn_closure do
    closure_number { 1 }
    report_date { "2025-11-17" }
    cash_collected { "9.99" }
    transfer_income { "9.99" }
    card_income { "9.99" }
    closed_by { "MyString" }
    theoretical_cash { "9.99" }
    payments_withdrawals { "9.99" }
    notes { "MyText" }
    user { nil }
  end
end
