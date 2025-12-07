class CreateDebtPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :debt_payments do |t|
      t.references :credit_purchase, null: false, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.date :payment_date, null: false
      t.integer :payment_number, null: false
      t.text :notes

      t.timestamps
    end

    add_index :debt_payments, :payment_date
    add_index :debt_payments, [ :credit_purchase_id, :payment_number ], unique: true, name: 'index_debt_payments_unique'
  end
end
