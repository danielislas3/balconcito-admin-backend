class AddBreakHoursToPayrollDays < ActiveRecord::Migration[8.1]
  def change
    add_column :payroll_days, :break_hours, :decimal, precision: 5, scale: 2, comment: "Horas de descanso personalizadas (si es null, usa el default de settings)"
  end
end
