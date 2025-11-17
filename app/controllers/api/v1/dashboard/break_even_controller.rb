module Api
  module V1
    module Dashboard
      class BreakEvenController < BaseController
        # GET /api/v1/dashboard/break_even
        def index
          render json: {
            period: {
              start_date: @start_date,
              end_date: @end_date
            },
            break_even_point: calculator.break_even_point,
            current_income: calculator.total_income,
            safety_margin: calculator.safety_margin,
            days_to_break_even: calculator.days_to_break_even,
            fixed_costs: calculator.fixed_costs_total,
            variable_costs: calculator.variable_costs_total,
            contribution_margin: calculator.contribution_margin,
            contribution_margin_percentage: calculator.contribution_margin_percentage,
            status: calculator.break_even_status
          }
        end
      end
    end
  end
end
