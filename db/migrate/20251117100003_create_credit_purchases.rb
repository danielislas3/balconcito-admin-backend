class CreateCreditPurchases < ActiveRecord::Migration[8.1]
  def change
    create_table :credit_purchases do |t|
      t.references :credit_card, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :concept, null: false
      t.decimal :total_amount, precision: 15, scale: 2, null: false
      t.decimal :monthly_payment, precision: 15, scale: 2, null: false
      t.integer :total_months, null: false, default: 1
      t.date :purchase_date, null: false
      t.decimal :remaining_balance, precision: 15, scale: 2, null: false
      t.integer :paid_months, default: 0, null: false
      t.boolean :fully_paid, default: false, null: false
      t.text :notes

      t.timestamps
    end

    add_index :credit_purchases, :purchase_date
    add_index :credit_purchases, :fully_paid
    add_index :credit_purchases, [ :user_id, :purchase_date ]
  end
end
