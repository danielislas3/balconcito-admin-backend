class CreateLoanPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :loan_payments do |t|
      t.references :loan, null: false, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.date :payment_date, null: false
      t.integer :payment_number, null: false
      t.text :notes

      t.timestamps
    end

    add_index :loan_payments, :payment_date
    add_index :loan_payments, [:loan_id, :payment_number], unique: true, name: 'index_loan_payments_unique'
  end
end
