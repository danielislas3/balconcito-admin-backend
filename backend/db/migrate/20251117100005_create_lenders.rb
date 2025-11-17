class CreateLenders < ActiveRecord::Migration[8.1]
  def change
    create_table :lenders do |t|
      t.string :name, null: false
      t.string :contact_email
      t.string :contact_phone
      t.string :relationship, null: false
      t.boolean :is_active, default: true, null: false
      t.text :notes

      t.timestamps
    end

    add_index :lenders, :name
    add_index :lenders, :is_active
  end
end
