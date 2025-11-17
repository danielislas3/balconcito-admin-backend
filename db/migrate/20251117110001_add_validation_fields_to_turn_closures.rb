class AddValidationFieldsToTurnClosures < ActiveRecord::Migration[8.1]
  def change
    add_column :turn_closures, :validation_data, :jsonb, default: {}, null: false
    add_column :turn_closures, :validated_at, :datetime
    add_column :turn_closures, :has_errors, :boolean, default: false, null: false
    add_column :turn_closures, :has_warnings, :boolean, default: false, null: false

    add_index :turn_closures, :validated_at
    add_index :turn_closures, :has_errors
    add_index :turn_closures, :has_warnings
    add_index :turn_closures, :validation_data, using: :gin
  end
end
