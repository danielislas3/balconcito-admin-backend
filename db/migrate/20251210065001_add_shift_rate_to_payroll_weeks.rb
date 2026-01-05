class AddShiftRateToPayrollWeeks < ActiveRecord::Migration[8.1]
  def change
    add_column :payroll_weeks, :shift_rate, :decimal, precision: 10, scale: 2, null: true, comment: "Custom shift rate for this week (overrides employee's base rate if set)"
  end
end
