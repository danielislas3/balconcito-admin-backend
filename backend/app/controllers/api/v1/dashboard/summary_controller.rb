module Api
  module V1
    module Dashboard
      class SummaryController < BaseController
        # GET /api/v1/dashboard/summary
        def index
          accounts = Account.all
          pending_reimbursements = Expense.pending_reimbursement

          render json: {
            period: {
              start_date: @start_date,
              end_date: @end_date,
              days: calculator.days_in_period
            },
            income: calculator.total_income,
            expenses: calculator.total_expenses,
            balance: calculator.net_profit,
            accounts: accounts.map do |a|
              {
                id: a.id,
                name: a.name,
                account_type: a.account_type,
                current_balance: a.current_balance
              }
            end,
            total_cash: calculator.total_cash_available,
            pending_reimbursements: pending_reimbursements.group_by(&:payment_source).transform_values do |expenses|
              {
                count: expenses.count,
                total: expenses.sum(&:amount)
              }
            end
          }
        end
      end
    end
  end
end
