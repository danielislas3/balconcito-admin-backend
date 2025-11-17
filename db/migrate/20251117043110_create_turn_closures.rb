class CreateTurnClosures < ActiveRecord::Migration[8.1]
  def change
    create_table :turn_closures do |t|
      t.integer :closure_number, null: false
      t.date :report_date, null: false
      t.decimal :cash_collected, precision: 15, scale: 2, default: 0.0, null: false
      t.decimal :transfer_income, precision: 15, scale: 2, default: 0.0, null: false
      t.decimal :card_income, precision: 15, scale: 2, default: 0.0, null: false
      t.string :closed_by, null: false
      t.decimal :theoretical_cash, precision: 15, scale: 2, default: 0.0, null: false
      t.decimal :payments_withdrawals, precision: 15, scale: 2, default: 0.0, null: false
      t.text :notes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :turn_closures, :closure_number, unique: true
    add_index :turn_closures, :report_date
  end
end
