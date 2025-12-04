class FixTurnClosuresComplete < ActiveRecord::Migration[8.1]
  def up
    # 1. Cambiar closure_number de integer a string (si aún es integer)
    if column_exists?(:turn_closures, :closure_number)
      current_type = connection.columns(:turn_closures).find { |c| c.name == 'closure_number' }.type
      if current_type == :integer
        change_column :turn_closures, :closure_number, :string, null: false
      end
    end

    # 2. Renombrar campos solo si existen con el nombre antiguo
    if column_exists?(:turn_closures, :report_date) && !column_exists?(:turn_closures, :closure_date)
      rename_column :turn_closures, :report_date, :closure_date
    end

    if column_exists?(:turn_closures, :card_income) && !column_exists?(:turn_closures, :card_income_gross)
      rename_column :turn_closures, :card_income, :card_income_gross
    end

    if column_exists?(:turn_closures, :transfer_income) && !column_exists?(:turn_closures, :transfer_income_gross)
      rename_column :turn_closures, :transfer_income, :transfer_income_gross
    end

    # 3. Agregar columna total_income si no existe
    unless column_exists?(:turn_closures, :total_income)
      add_column :turn_closures, :total_income, :decimal, precision: 15, scale: 2, default: 0.0, null: false
    end
  end

  def down
    if column_exists?(:turn_closures, :total_income)
      remove_column :turn_closures, :total_income
    end

    if column_exists?(:turn_closures, :transfer_income_gross)
      rename_column :turn_closures, :transfer_income_gross, :transfer_income
    end

    if column_exists?(:turn_closures, :card_income_gross)
      rename_column :turn_closures, :card_income_gross, :card_income
    end

    if column_exists?(:turn_closures, :closure_date)
      rename_column :turn_closures, :closure_date, :report_date
    end

    current_type = connection.columns(:turn_closures).find { |c| c.name == 'closure_number' }.type
    if current_type == :string
      change_column :turn_closures, :closure_number, :integer, null: false, using: 'closure_number::integer'
    end
  end
end
