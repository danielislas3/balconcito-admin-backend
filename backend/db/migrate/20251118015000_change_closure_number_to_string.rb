class ChangeClosureNumberToString < ActiveRecord::Migration[8.1]
  def up
    # Cambiar closure_number de integer a string
    change_column :turn_closures, :closure_number, :string, null: false
  end

  def down
    # Revertir a integer (solo funciona si todos los valores son numéricos)
    change_column :turn_closures, :closure_number, :integer, null: false, using: 'closure_number::integer'
  end
end
