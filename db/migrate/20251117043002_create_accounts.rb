class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :account_type, null: false
      t.decimal :current_balance, precision: 15, scale: 2, default: 0.0, null: false
      t.text :description

      t.timestamps
    end

    add_index :accounts, :name, unique: true
    add_index :accounts, :account_type
  end
end
