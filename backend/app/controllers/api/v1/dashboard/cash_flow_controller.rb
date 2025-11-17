module Api
  module V1
    module Dashboard
      class CashFlowController < BaseController
        # GET /api/v1/dashboard/cash_flow
        def index
          render json: {
            period: {
              start_date: @start_date,
              end_date: @end_date
            },
            total_cash_available: calculator.total_cash_available,
            cash_runway_days: calculator.cash_runway_days,
            average_daily_expenses: calculator.average_daily_expenses,
            average_daily_income: calculator.average_daily_income,
            net_daily_cash_flow: calculator.net_daily_cash_flow,
            accounts: Account.all.map { |a|
              {
                id: a.id,
                name: a.name,
                account_type: a.account_type,
                current_balance: a.current_balance
              }
            },
            status: calculator.cash_flow_status
          }
        end
      end
    end
  end
end
