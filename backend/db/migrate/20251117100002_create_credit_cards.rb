class CreateCreditCards < ActiveRecord::Migration[8.1]
  def change
    create_table :credit_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :bank_name, null: false
      t.integer :cut_day, null: false
      t.decimal :credit_limit, precision: 15, scale: 2, default: 0
      t.integer :statement_day
      t.boolean :is_active, default: true, null: false
      t.text :notes

      t.timestamps
    end

    add_index :credit_cards, [:user_id, :name], unique: true
    add_index :credit_cards, :is_active
  end
end
