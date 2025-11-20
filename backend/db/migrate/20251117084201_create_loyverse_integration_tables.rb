class CreateLoyverseIntegrationTables < ActiveRecord::Migration[8.1]
  def change
    # Tabla para almacenar receipts de Loyverse
    create_table :loyverse_receipts do |t|
      t.string :loyverse_id, null: false
      t.string :receipt_number
      t.string :receipt_type # SALE, REFUND, etc.
      t.decimal :total_money, precision: 15, scale: 2
      t.decimal :total_tax, precision: 15, scale: 2
      t.jsonb :receipt_data, default: {}, null: false
      t.datetime :loyverse_created_at
      t.datetime :synced_at
      t.references :turn_closure, foreign_key: true
      t.timestamps

      t.index :loyverse_id, unique: true
      t.index :receipt_number
      t.index :synced_at
      t.index :loyverse_created_at
    end

    # Tabla para log de webhooks recibidos
    create_table :loyverse_webhook_events do |t|
      t.string :event_id
      t.string :event_type, null: false # RECEIPT_CREATED, ITEM_UPDATED, etc.
      t.jsonb :payload, default: {}, null: false
      t.boolean :processed, default: false, null: false
      t.datetime :processed_at
      t.text :error_message
      t.string :signature # X-Loyverse-Webhook-Signature
      t.timestamps

      t.index :event_id, unique: true, where: "event_id IS NOT NULL"
      t.index :event_type
      t.index :processed
      t.index :created_at
    end

    # Tabla para configuración de Loyverse
    create_table :loyverse_configs do |t|
      t.text :api_token_encrypted
      t.text :webhook_secret_encrypted
      t.jsonb :payment_type_mappings, default: {}, null: false
      t.datetime :last_sync_at
      t.boolean :sync_enabled, default: true, null: false
      t.timestamps
    end

    # Tabla para mapear payment types de Loyverse a PaymentMethods
    create_table :loyverse_payment_mappings do |t|
      t.string :loyverse_payment_type_id, null: false
      t.string :loyverse_payment_name, null: false
      t.string :loyverse_payment_type # CASH, CARD, CUSTOM
      t.references :payment_method, foreign_key: true
      t.boolean :is_active, default: true, null: false
      t.timestamps

      t.index :loyverse_payment_type_id, unique: true
    end
  end
end
