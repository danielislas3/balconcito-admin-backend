class CreateLoans < ActiveRecord::Migration[8.1]
  def change
    create_table :loans do |t|
      t.references :lender, null: false, foreign_key: true
      t.decimal :principal_amount, precision: 15, scale: 2, null: false
      t.decimal :interest_rate, precision: 5, scale: 2, default: 0, null: false
      t.integer :term_months, null: false
      t.date :loan_date, null: false
      t.date :due_date
      t.decimal :remaining_balance, precision: 15, scale: 2, null: false
      t.boolean :is_paid, default: false, null: false
      t.text :notes

      t.timestamps
    end

    add_index :loans, :loan_date
    add_index :loans, :is_paid
    add_index :loans, :due_date
  end
end
