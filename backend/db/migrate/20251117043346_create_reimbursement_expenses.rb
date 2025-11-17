class CreateReimbursementExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :reimbursement_expenses do |t|
      t.references :reimbursement, null: false, foreign_key: { on_delete: :cascade }
      t.references :expense, null: false, foreign_key: { on_delete: :cascade }
      t.decimal :amount, precision: 15, scale: 2, null: false

      t.timestamps
    end
  end
end
