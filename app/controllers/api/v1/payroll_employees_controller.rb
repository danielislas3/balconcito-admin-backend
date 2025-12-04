module Api
  module V1
    class PayrollEmployeesController < ApplicationController
      before_action :set_payroll_employee, only: [:show, :update, :destroy]

      # GET /api/v1/payroll_employees
      def index
        employees = PayrollEmployee.includes(:payroll_weeks).by_name

        render json: {
          employees: employees.map(&:to_frontend_json),
          count: employees.count
        }
      end

      # GET /api/v1/payroll_employees/:id
      def show
        render json: {
          employee: @payroll_employee.to_frontend_json
        }
      end

      # POST /api/v1/payroll_employees
      def create
        employee = PayrollEmployee.new(payroll_employee_params)
        employee.user_id = current_user.id if params[:link_to_current_user]

        if employee.save
          render json: {
            employee: employee.to_frontend_json,
            message: 'Empleado creado exitosamente'
          }, status: :created
        else
          render_error(employee.errors.full_messages.join(', '))
        end
      end

      # PATCH /api/v1/payroll_employees/:id
      def update
        if @payroll_employee.update(payroll_employee_params)
          render json: {
            employee: @payroll_employee.to_frontend_json,
            message: 'Empleado actualizado exitosamente'
          }
        else
          render_error(@payroll_employee.errors.full_messages.join(', '))
        end
      end

      # DELETE /api/v1/payroll_employees/:id
      def destroy
        if @payroll_employee.destroy
          render json: { message: 'Empleado eliminado exitosamente' }
        else
          render_error('No se pudo eliminar el empleado')
        end
      end

      # POST /api/v1/payroll_employees/import
      def import
        data = JSON.parse(params[:data])
        imported_count = 0
        errors = []

        ActiveRecord::Base.transaction do
          data['employees']&.each do |emp_data|
            employee = PayrollEmployee.find_or_initialize_by(employee_id: emp_data['id'])
            employee.assign_attributes(
              name: emp_data['name'],
              base_hourly_rate: emp_data.dig('settings', 'baseHourlyRate') || 0,
              currency: emp_data.dig('settings', 'currency') || 'MXN',
              uses_overtime: emp_data.dig('settings', 'usesOvertime') != false,
              uses_tips: emp_data.dig('settings', 'usesTips') || false,
              overtime_tier1_rate: emp_data.dig('settings', 'overtimeTier1Rate') || 1.5,
              overtime_tier2_rate: emp_data.dig('settings', 'overtimeTier2Rate') || 2.0,
              overtime_tier1_hours: emp_data.dig('settings', 'overtimeTier1Hours') || 2,
              hours_per_shift: emp_data.dig('settings', 'hoursPerShift') || 8,
              break_hours: emp_data.dig('settings', 'breakHours') || 1,
              min_hours_for_break: emp_data.dig('settings', 'minHoursForBreak') || 5
            )

            if employee.save
              # Importar semanas
              emp_data['weeks']&.each do |week_data|
                import_week(employee, week_data)
              end
              imported_count += 1
            else
              errors << "#{emp_data['name']}: #{employee.errors.full_messages.join(', ')}"
            end
          end
        end

        if errors.empty?
          render json: { message: "#{imported_count} empleados importados exitosamente", count: imported_count }
        else
          render_error("Errores en importación: #{errors.join('; ')}")
        end
      rescue JSON::ParserError => e
        render_error("Error al parsear JSON: #{e.message}")
      end

      # GET /api/v1/payroll_employees/export
      def export
        employees = PayrollEmployee.includes(payroll_weeks: :payroll_days).by_name

        data = {
          employees: employees.map(&:to_frontend_json),
          exportedAt: Time.current.iso8601,
          version: '1.0'
        }

        render json: data
      end

      private

      def set_payroll_employee
        @payroll_employee = PayrollEmployee.find_by!(employee_id: params[:id]) ||
                            PayrollEmployee.find(params[:id])
      end

      def payroll_employee_params
        params.require(:payroll_employee).permit(
          :name, :employee_id, :user_id, :base_hourly_rate, :currency,
          :uses_overtime, :uses_tips, :overtime_tier1_rate, :overtime_tier2_rate,
          :overtime_tier1_hours, :hours_per_shift, :break_hours, :min_hours_for_break
        )
      end

      def import_week(employee, week_data)
        week = employee.payroll_weeks.find_or_initialize_by(week_id: week_data['id'])
        week.assign_attributes(
          start_date: Date.parse(week_data['startDate']),
          end_date: Date.parse(week_data['startDate']) + 6.days,
          weekly_tips: week_data['weeklyTips'] || 0
        )

        if week.save
          # Importar días
          week_data['schedule']&.each do |day_key, day_data|
            import_day(week, day_key, day_data)
          end
          week.recalculate_and_save!
        end
      end

      def import_day(week, day_key, day_data)
        day = week.payroll_days.find_or_initialize_by(day_key: day_key)
        day.update_schedule(
          entryHour: day_data['entryHour'],
          entryMinute: day_data['entryMinute'],
          exitHour: day_data['exitHour'],
          exitMinute: day_data['exitMinute'],
          isWorking: day_data['isWorking'] || false
        )
      end
    end
  end
end
