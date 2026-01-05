module Api
  module V1
    class PayrollWeeksController < ApplicationController
      before_action :set_payroll_employee
      before_action :set_payroll_week, only: [ :show, :update, :destroy ]

      # GET /api/v1/payroll_employees/:employee_id/weeks
      def index
        weeks = @payroll_employee.payroll_weeks.includes(:payroll_days).by_date

        render json: {
          weeks: weeks.map(&:to_frontend_json),
          count: weeks.count
        }
      end

      # GET /api/v1/payroll_employees/:employee_id/weeks/:id
      def show
        render json: {
          week: @payroll_week.to_frontend_json
        }
      end

      # POST /api/v1/payroll_employees/:employee_id/weeks
      def create
        week = @payroll_employee.payroll_weeks.new(payroll_week_params)

        # Auto-generar week_id si no se proporciona
        if week.week_id.blank?
          week.week_id = "#{week.start_date.year}-W#{week.start_date.cweek.to_s.rjust(2, '0')}"
        end

        # Auto-calcular end_date si no se proporciona
        if week.end_date.blank?
          week.end_date = week.start_date + 6.days
        end

        if week.save
          render json: {
            week: week.to_frontend_json,
            message: "Semana creada exitosamente"
          }, status: :created
        else
          render_error(week.errors.full_messages.join(", "))
        end
      end

      # PATCH /api/v1/payroll_employees/:employee_id/weeks/:id
      def update
        if @payroll_week.update(payroll_week_params)
          @payroll_week.recalculate_and_save!

          render json: {
            week: @payroll_week.reload.to_frontend_json,
            message: "Semana actualizada exitosamente"
          }
        else
          render_error(@payroll_week.errors.full_messages.join(", "))
        end
      end

      # DELETE /api/v1/payroll_employees/:employee_id/weeks/:id
      def destroy
        if @payroll_week.destroy
          render json: { message: "Semana eliminada exitosamente" }
        else
          render_error("No se pudo eliminar la semana")
        end
      end

      # PATCH /api/v1/payroll_employees/:employee_id/weeks/:id/update_schedule
      def update_schedule
        set_payroll_week

        # Actualizar cada día del horario
        schedule_params = params.require(:schedule)
        updated_days = []
        errors = []

        schedule_params.each do |day_key, day_data|
          day = @payroll_week.payroll_days.find_or_initialize_by(day_key: day_key)

          # IMPORTANTE: Solo permitir campos de entrada (horarios), NO valores calculados
          # El backend calculará automáticamente: hoursWorked, regularHours, overtimeHours, extraHours, dailyPay
          allowed_params = day_data.permit(:entryHour, :entryMinute, :exitHour, :exitMinute, :isWorking).to_h.symbolize_keys

          if day.update_schedule(allowed_params)
            updated_days << day_key
          else
            errors << "#{day_key}: #{day.errors.full_messages.join(', ')}"
          end
        end

        # Si hubo errores, retornar
        if errors.any?
          return render_error("Errores al actualizar horarios: #{errors.join(' | ')}")
        end

        # Recalcular totales de la semana
        @payroll_week.recalculate_and_save!

        render json: {
          week: @payroll_week.reload.to_frontend_json,
          message: "Horario actualizado para #{updated_days.count} días"
        }
      rescue ActionController::ParameterMissing => e
        render_error("Falta el parámetro 'schedule': #{e.message}")
      end

      private

      def set_payroll_employee
        # Try to find by employee_id first (custom ID), fallback to database ID
        @payroll_employee = PayrollEmployee.find_by(employee_id: params[:payroll_employee_id]) ||
                            PayrollEmployee.find(params[:payroll_employee_id])
      end

      def set_payroll_week
        # Try to find by week_id first (custom ID like "2025-W39"), fallback to database ID
        @payroll_week = @payroll_employee.payroll_weeks.find_by(week_id: params[:id]) ||
                        @payroll_employee.payroll_weeks.find(params[:id])
      end

      def payroll_week_params
        params.require(:payroll_week).permit(:week_id, :start_date, :end_date, :weekly_tips, :shift_rate)
      end
    end
  end
end
