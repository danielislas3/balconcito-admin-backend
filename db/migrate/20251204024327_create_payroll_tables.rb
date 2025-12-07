class CreatePayrollTables < ActiveRecord::Migration[8.1]
  def change
    # Payroll Employees - Empleados del sistema de nómina
    create_table :payroll_employees do |t|
      t.string :name, null: false
      t.string :employee_id, null: false # ID único del empleado
      t.references :user, null: true, foreign_key: true # Opcional: vincular a usuario del sistema

      # Settings - Configuración del empleado
      t.decimal :base_hourly_rate, precision: 10, scale: 2, null: false, default: 0
      t.string :currency, default: 'MXN', null: false
      t.boolean :uses_overtime, default: true, null: false
      t.boolean :uses_tips, default: false, null: false

      # Overtime configuration
      t.decimal :overtime_tier1_rate, precision: 5, scale: 2, default: 1.5 # 150%
      t.decimal :overtime_tier2_rate, precision: 5, scale: 2, default: 2.0 # 200%
      t.integer :overtime_tier1_hours, default: 2 # Primeras 2 horas extras

      # Break time configuration
      t.integer :hours_per_shift, default: 8 # Horas pagadas por turno (sin descanso)
      t.integer :break_hours, default: 1 # Horas de descanso
      t.integer :min_hours_for_break, default: 5 # Mínimo de horas para descanso obligatorio

      t.timestamps
    end

    add_index :payroll_employees, :employee_id, unique: true
    add_index :payroll_employees, :name

    # Payroll Weeks - Semanas de nómina
    create_table :payroll_weeks do |t|
      t.references :payroll_employee, null: false, foreign_key: true
      t.string :week_id, null: false # Formato: YYYY-WW
      t.date :start_date, null: false
      t.date :end_date, null: false

      # Tips semanales
      t.decimal :weekly_tips, precision: 10, scale: 2, default: 0

      # Totales calculados (desnormalizados para performance)
      t.decimal :total_hours, precision: 10, scale: 2, default: 0
      t.decimal :total_regular_hours, precision: 10, scale: 2, default: 0
      t.decimal :total_overtime_hours, precision: 10, scale: 2, default: 0
      t.decimal :total_extra_hours, precision: 10, scale: 2, default: 0
      t.decimal :total_base_pay, precision: 10, scale: 2, default: 0
      t.decimal :total_pay, precision: 10, scale: 2, default: 0 # base_pay + tips
      t.integer :total_shifts, default: 0

      t.timestamps
    end

    add_index :payroll_weeks, [ :payroll_employee_id, :week_id ], unique: true
    add_index :payroll_weeks, :start_date
    add_index :payroll_weeks, :week_id

    # Payroll Days - Días individuales de trabajo
    create_table :payroll_days do |t|
      t.references :payroll_week, null: false, foreign_key: true
      t.string :day_key, null: false # 'monday', 'tuesday', etc.
      t.date :date, null: false

      # Horarios
      t.string :entry_hour # "17"
      t.string :entry_minute # "00"
      t.string :exit_hour # "02"
      t.string :exit_minute # "00"

      # Cálculos del día
      t.decimal :hours_worked, precision: 5, scale: 2, default: 0
      t.decimal :regular_hours, precision: 5, scale: 2, default: 0
      t.decimal :overtime_hours, precision: 5, scale: 2, default: 0
      t.decimal :extra_hours, precision: 5, scale: 2, default: 0
      t.decimal :daily_pay, precision: 10, scale: 2, default: 0
      t.boolean :is_working, default: false

      t.timestamps
    end

    add_index :payroll_days, [ :payroll_week_id, :day_key ], unique: true
    add_index :payroll_days, :date
  end
end
