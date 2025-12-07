class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.date :expense_date, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.text :description, null: false
      t.string :category, null: false
      t.string :payment_source, null: false
      t.string :provider
      t.string :receipt_photo_url, limit: 500
      t.boolean :requires_reimbursement, default: false, null: false
      t.boolean :reimbursed, default: false, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :expenses, :expense_date
    add_index :expenses, :category
    add_index :expenses, :payment_source
    add_index :expenses, [ :requires_reimbursement, :reimbursed ]
  end
end
