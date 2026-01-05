class AddForceOvertimeToPayrollDays < ActiveRecord::Migration[8.1]
  def change
    add_column :payroll_days, :force_overtime, :boolean, default: false, null: false, comment: "Si es true, todas las horas se pagan como overtime (útil para lunes de madrugada)"
  end
end
