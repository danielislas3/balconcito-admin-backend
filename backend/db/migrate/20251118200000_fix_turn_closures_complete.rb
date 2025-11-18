class FixTurnClosuresComplete < ActiveRecord::Migration[8.1]
  def up
    # 1. Cambiar closure_number de integer a string
    change_column :turn_closures, :closure_number, :string, null: false

    # 2. Renombrar campos para que coincidan con el modelo
    rename_column :turn_closures, :report_date, :closure_date
    rename_column :turn_closures, :card_income, :card_income_gross
    rename_column :turn_closures, :transfer_income, :transfer_income_gross

    # 3. Agregar columna total_income
    add_column :turn_closures, :total_income, :decimal, precision: 15, scale: 2, default: 0.0, null: false
  end

  def down
    remove_column :turn_closures, :total_income
    rename_column :turn_closures, :transfer_income_gross, :transfer_income
    rename_column :turn_closures, :card_income_gross, :card_income
    rename_column :turn_closures, :closure_date, :report_date
    change_column :turn_closures, :closure_number, :integer, null: false, using: 'closure_number::integer'
  end
end
