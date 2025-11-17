class AddLoyverseShiftSupport < ActiveRecord::Migration[8.1]
  def change
    # Tabla para almacenar shifts de Loyverse
    create_table :loyverse_shifts do |t|
      # Identificadores
      t.string :loyverse_id, null: false
      t.string :store_id
      t.string :pos_device_id

      # Tiempos
      t.datetime :opened_at
      t.datetime :closed_at

      # Empleados
      t.string :opened_by_employee
      t.string :closed_by_employee

      # Totales de efectivo
      t.decimal :starting_cash, precision: 15, scale: 2, default: 0
      t.decimal :cash_payments, precision: 15, scale: 2, default: 0
      t.decimal :cash_refunds, precision: 15, scale: 2, default: 0
      t.decimal :paid_in, precision: 15, scale: 2, default: 0
      t.decimal :paid_out, precision: 15, scale: 2, default: 0
      t.decimal :expected_cash, precision: 15, scale: 2, default: 0
      t.decimal :actual_cash, precision: 15, scale: 2, default: 0

      # Totales de ventas
      t.decimal :gross_sales, precision: 15, scale: 2, default: 0
      t.decimal :refunds, precision: 15, scale: 2, default: 0
      t.decimal :discounts, precision: 15, scale: 2, default: 0

      # Extras
      t.decimal :tip, precision: 15, scale: 2, default: 0
      t.decimal :surcharge, precision: 15, scale: 2, default: 0

      # JSON completo del shift
      t.jsonb :shift_data, default: {}, null: false

      # Relación con TurnClosure
      t.references :turn_closure, foreign_key: true

      # Timestamps
      t.timestamps

      # Índices
      t.index :loyverse_id, unique: true
      t.index :closed_at
      t.index :store_id
    end

    # Agregar shift_id a loyverse_receipts
    add_reference :loyverse_receipts, :loyverse_shift, foreign_key: true
    add_index :loyverse_receipts, :loyverse_shift_id
  end
end
