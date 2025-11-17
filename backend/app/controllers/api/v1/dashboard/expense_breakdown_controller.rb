module Api
  module V1
    module Dashboard
      class ExpenseBreakdownController < BaseController
        # GET /api/v1/dashboard/expense_breakdown
        def index
          render json: {
            period: {
              start_date: @start_date,
              end_date: @end_date
            },
            total_expenses: calculator.total_expenses,
            by_cost_type: {
              cogs: {
                total: calculator.cogs_total,
                percentage: calculator.cogs_percentage
              },
              fixed: {
                total: calculator.fixed_costs_total,
                percentage: calculator.fixed_costs_percentage
              },
              variable: {
                total: calculator.variable_costs_total,
                percentage: calculator.variable_costs_percentage
              },
              payroll: {
                total: calculator.payroll_total,
                percentage: calculator.labor_cost_percentage
              }
            },
            by_category: calculator.expenses_by_category,
            by_payment_source: calculator.expenses_by_payment_source,
            top_expenses: calculator.top_expenses(10)
          }
        end
      end
    end
  end
end
