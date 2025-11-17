module Api
  module V1
    module Dashboard
      class ProfitabilityController < BaseController
        # GET /api/v1/dashboard/profitability
        def index
          render json: {
            period: {
              start_date: @start_date,
              end_date: @end_date
            },
            net_profit: calculator.net_profit,
            net_margin: calculator.net_margin,
            cogs_percentage: calculator.cogs_percentage,
            labor_cost_percentage: calculator.labor_cost_percentage,
            contribution_margin: calculator.contribution_margin_percentage,
            income: calculator.total_income,
            expenses: {
              total: calculator.total_expenses,
              cogs: calculator.cogs_total,
              fixed: calculator.fixed_costs_total,
              variable: calculator.variable_costs_total,
              payroll: calculator.payroll_total
            },
            status: calculator.cogs_status
          }
        end
      end
    end
  end
end
