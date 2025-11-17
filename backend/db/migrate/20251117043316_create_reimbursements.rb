class CreateReimbursements < ActiveRecord::Migration[8.1]
  def change
    create_table :reimbursements do |t|
      t.date :reimbursement_date, null: false
      t.references :to_user, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.references :from_account, null: false, foreign_key: { to_table: :accounts }
      t.text :notes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :reimbursements, :reimbursement_date
  end
end
