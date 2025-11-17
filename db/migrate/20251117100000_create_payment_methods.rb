class CreatePaymentMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_methods do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :payment_type, null: false
      t.boolean :requires_reimbursement, default: false, null: false
      t.boolean :is_active, default: true, null: false
      t.text :description

      t.timestamps
    end

    add_index :payment_methods, :payment_type
    add_index :payment_methods, :is_active
    add_index :payment_methods, [ :user_id, :name ], unique: true
  end
end
