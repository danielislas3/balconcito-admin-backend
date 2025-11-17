class AddPaymentMethodToExpenses < ActiveRecord::Migration[8.1]
  def change
    # Agregar payment_method_id como nullable para permitir migración de datos existentes
    add_reference :expenses, :payment_method, foreign_key: true, null: true

    # Remover el enum payment_source hardcodeado
    remove_column :expenses, :payment_source, :string
  end
end
