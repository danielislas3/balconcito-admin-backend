class FixTurnClosuresFields < ActiveRecord::Migration[8.1]
  def change
    # 1. Renombrar report_date a closure_date (el modelo espera closure_date)
    rename_column :turn_closures, :report_date, :closure_date

    # 2. Renombrar card_income a card_income_gross (el modelo espera card_income_gross)
    rename_column :turn_closures, :card_income, :card_income_gross

    # 3. Renombrar transfer_income a transfer_income_gross (el modelo espera transfer_income_gross)
    rename_column :turn_closures, :transfer_income, :transfer_income_gross

    # 4. Agregar total_income (suma calculada de todos los ingresos)
    add_column :turn_closures, :total_income, :decimal, precision: 15, scale: 2, default: 0.0, null: false

    # 5. Agregar index en closure_date (antes report_date)
    add_index :turn_closures, :closure_date unless index_exists?(:turn_closures, :closure_date)
  end
end
