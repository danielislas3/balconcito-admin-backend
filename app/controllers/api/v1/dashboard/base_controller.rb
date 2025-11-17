module Api
  module V1
    module Dashboard
      class BaseController < ApplicationController
        before_action :set_date_range

        private

        def set_date_range
          period = params[:period] || 'month'
          date = params[:date] ? Date.parse(params[:date]) : Date.today

          case period
          when 'day'
            @start_date = date
            @end_date = date
          when 'week'
            @start_date = date.beginning_of_week
            @end_date = date.end_of_week
          when 'month'
            @start_date = date.beginning_of_month
            @end_date = date.end_of_month
          when 'year'
            @start_date = date.beginning_of_year
            @end_date = date.end_of_year
          when 'custom'
            @start_date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
            @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today
          else
            @start_date = date.beginning_of_month
            @end_date = date.end_of_month
          end
        end

        def calculator
          @calculator ||= MetricsCalculator.new(@start_date, @end_date)
        end
      end
    end
  end
end
