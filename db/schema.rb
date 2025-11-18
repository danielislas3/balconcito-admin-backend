# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_18_200000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "account_type", null: false
    t.datetime "created_at", null: false
    t.decimal "current_balance", precision: 15, scale: 2, default: "0.0", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["account_type"], name: "index_accounts_on_account_type"
    t.index ["name"], name: "index_accounts_on_name", unique: true
  end

  create_table "credit_cards", force: :cascade do |t|
    t.string "bank_name", null: false
    t.datetime "created_at", null: false
    t.decimal "credit_limit", precision: 15, scale: 2, default: "0.0"
    t.integer "cut_day", null: false
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.text "notes"
    t.integer "statement_day"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["is_active"], name: "index_credit_cards_on_is_active"
    t.index ["user_id", "name"], name: "index_credit_cards_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_credit_cards_on_user_id"
  end

  create_table "credit_purchases", force: :cascade do |t|
    t.string "concept", null: false
    t.datetime "created_at", null: false
    t.integer "credit_card_id", null: false
    t.boolean "fully_paid", default: false, null: false
    t.decimal "monthly_payment", precision: 15, scale: 2, null: false
    t.text "notes"
    t.integer "paid_months", default: 0, null: false
    t.date "purchase_date", null: false
    t.decimal "remaining_balance", precision: 15, scale: 2, null: false
    t.decimal "total_amount", precision: 15, scale: 2, null: false
    t.integer "total_months", default: 1, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["credit_card_id"], name: "index_credit_purchases_on_credit_card_id"
    t.index ["fully_paid"], name: "index_credit_purchases_on_fully_paid"
    t.index ["purchase_date"], name: "index_credit_purchases_on_purchase_date"
    t.index ["user_id", "purchase_date"], name: "index_credit_purchases_on_user_id_and_purchase_date"
    t.index ["user_id"], name: "index_credit_purchases_on_user_id"
  end

  create_table "debt_payments", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.integer "credit_purchase_id", null: false
    t.text "notes"
    t.date "payment_date", null: false
    t.integer "payment_number", null: false
    t.datetime "updated_at", null: false
    t.index ["credit_purchase_id", "payment_number"], name: "index_debt_payments_unique", unique: true
    t.index ["credit_purchase_id"], name: "index_debt_payments_on_credit_purchase_id"
    t.index ["payment_date"], name: "index_debt_payments_on_payment_date"
  end

  create_table "expenses", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.date "expense_date", null: false
    t.integer "payment_method_id"
    t.string "provider"
    t.string "receipt_photo_url", limit: 500
    t.boolean "reimbursed", default: false, null: false
    t.boolean "requires_reimbursement", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["category"], name: "index_expenses_on_category"
    t.index ["expense_date"], name: "index_expenses_on_expense_date"
    t.index ["payment_method_id"], name: "index_expenses_on_payment_method_id"
    t.index ["requires_reimbursement", "reimbursed"], name: "index_expenses_on_requires_reimbursement_and_reimbursed"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp"
    t.string "jti", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "lenders", force: :cascade do |t|
    t.string "contact_email"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.text "notes"
    t.string "relationship", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_lenders_on_is_active"
    t.index ["name"], name: "index_lenders_on_name"
  end

  create_table "loan_payments", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.integer "loan_id", null: false
    t.text "notes"
    t.date "payment_date", null: false
    t.integer "payment_number", null: false
    t.datetime "updated_at", null: false
    t.index ["loan_id", "payment_number"], name: "index_loan_payments_unique", unique: true
    t.index ["loan_id"], name: "index_loan_payments_on_loan_id"
    t.index ["payment_date"], name: "index_loan_payments_on_payment_date"
  end

  create_table "loans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "due_date"
    t.decimal "interest_rate", precision: 5, scale: 2, default: "0.0", null: false
    t.boolean "is_paid", default: false, null: false
    t.integer "lender_id", null: false
    t.date "loan_date", null: false
    t.text "notes"
    t.decimal "principal_amount", precision: 15, scale: 2, null: false
    t.decimal "remaining_balance", precision: 15, scale: 2, null: false
    t.integer "term_months", null: false
    t.datetime "updated_at", null: false
    t.index ["due_date"], name: "index_loans_on_due_date"
    t.index ["is_paid"], name: "index_loans_on_is_paid"
    t.index ["lender_id"], name: "index_loans_on_lender_id"
    t.index ["loan_date"], name: "index_loans_on_loan_date"
  end

  create_table "loyverse_configs", force: :cascade do |t|
    t.text "api_token_encrypted"
    t.datetime "created_at", null: false
    t.datetime "last_sync_at"
    t.jsonb "payment_type_mappings", default: {}, null: false
    t.boolean "sync_enabled", default: true, null: false
    t.datetime "updated_at", null: false
    t.text "webhook_secret_encrypted"
  end

  create_table "loyverse_payment_mappings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active", default: true, null: false
    t.string "loyverse_payment_name", null: false
    t.string "loyverse_payment_type"
    t.string "loyverse_payment_type_id", null: false
    t.bigint "payment_method_id"
    t.datetime "updated_at", null: false
    t.index ["loyverse_payment_type_id"], name: "index_loyverse_payment_mappings_on_loyverse_payment_type_id", unique: true
    t.index ["payment_method_id"], name: "index_loyverse_payment_mappings_on_payment_method_id"
  end

  create_table "loyverse_receipts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "loyverse_created_at"
    t.string "loyverse_id", null: false
    t.bigint "loyverse_shift_id"
    t.jsonb "receipt_data", default: {}, null: false
    t.string "receipt_number"
    t.string "receipt_type"
    t.datetime "synced_at"
    t.decimal "total_money", precision: 15, scale: 2
    t.decimal "total_tax", precision: 15, scale: 2
    t.bigint "turn_closure_id"
    t.datetime "updated_at", null: false
    t.index ["loyverse_created_at"], name: "index_loyverse_receipts_on_loyverse_created_at"
    t.index ["loyverse_id"], name: "index_loyverse_receipts_on_loyverse_id", unique: true
    t.index ["loyverse_shift_id"], name: "index_loyverse_receipts_on_loyverse_shift_id"
    t.index ["receipt_number"], name: "index_loyverse_receipts_on_receipt_number"
    t.index ["synced_at"], name: "index_loyverse_receipts_on_synced_at"
    t.index ["turn_closure_id"], name: "index_loyverse_receipts_on_turn_closure_id"
  end

  create_table "loyverse_shifts", force: :cascade do |t|
    t.decimal "actual_cash", precision: 15, scale: 2, default: "0.0"
    t.decimal "cash_payments", precision: 15, scale: 2, default: "0.0"
    t.decimal "cash_refunds", precision: 15, scale: 2, default: "0.0"
    t.datetime "closed_at"
    t.string "closed_by_employee"
    t.datetime "created_at", null: false
    t.decimal "discounts", precision: 15, scale: 2, default: "0.0"
    t.decimal "expected_cash", precision: 15, scale: 2, default: "0.0"
    t.decimal "gross_sales", precision: 15, scale: 2, default: "0.0"
    t.string "loyverse_id", null: false
    t.datetime "opened_at"
    t.string "opened_by_employee"
    t.decimal "paid_in", precision: 15, scale: 2, default: "0.0"
    t.decimal "paid_out", precision: 15, scale: 2, default: "0.0"
    t.string "pos_device_id"
    t.decimal "refunds", precision: 15, scale: 2, default: "0.0"
    t.jsonb "shift_data", default: {}, null: false
    t.decimal "starting_cash", precision: 15, scale: 2, default: "0.0"
    t.string "store_id"
    t.decimal "surcharge", precision: 15, scale: 2, default: "0.0"
    t.decimal "tip", precision: 15, scale: 2, default: "0.0"
    t.bigint "turn_closure_id"
    t.datetime "updated_at", null: false
    t.index ["closed_at"], name: "index_loyverse_shifts_on_closed_at"
    t.index ["loyverse_id"], name: "index_loyverse_shifts_on_loyverse_id", unique: true
    t.index ["store_id"], name: "index_loyverse_shifts_on_store_id"
    t.index ["turn_closure_id"], name: "index_loyverse_shifts_on_turn_closure_id"
  end

  create_table "loyverse_webhook_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "event_id"
    t.string "event_type", null: false
    t.jsonb "payload", default: {}, null: false
    t.boolean "processed", default: false, null: false
    t.datetime "processed_at"
    t.string "signature"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_loyverse_webhook_events_on_created_at"
    t.index ["event_id"], name: "index_loyverse_webhook_events_on_event_id", unique: true, where: "(event_id IS NOT NULL)"
    t.index ["event_type"], name: "index_loyverse_webhook_events_on_event_type"
    t.index ["processed"], name: "index_loyverse_webhook_events_on_processed"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.string "payment_type", null: false
    t.boolean "requires_reimbursement", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["is_active"], name: "index_payment_methods_on_is_active"
    t.index ["payment_type"], name: "index_payment_methods_on_payment_type"
    t.index ["user_id", "name"], name: "index_payment_methods_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "reimbursement_expenses", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.integer "expense_id", null: false
    t.integer "reimbursement_id", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_id"], name: "index_reimbursement_expenses_on_expense_id"
    t.index ["reimbursement_id"], name: "index_reimbursement_expenses_on_reimbursement_id"
  end

  create_table "reimbursements", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.integer "from_account_id", null: false
    t.text "notes"
    t.date "reimbursement_date", null: false
    t.integer "to_user_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["from_account_id"], name: "index_reimbursements_on_from_account_id"
    t.index ["reimbursement_date"], name: "index_reimbursements_on_reimbursement_date"
    t.index ["to_user_id"], name: "index_reimbursements_on_to_user_id"
    t.index ["user_id"], name: "index_reimbursements_on_user_id"
  end

  create_table "turn_closures", force: :cascade do |t|
    t.decimal "card_income_gross", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "cash_collected", precision: 15, scale: 2, default: "0.0", null: false
    t.string "closed_by", null: false
    t.date "closure_date", null: false
    t.string "closure_number", null: false
    t.datetime "created_at", null: false
    t.boolean "has_errors", default: false, null: false
    t.boolean "has_warnings", default: false, null: false
    t.text "notes"
    t.decimal "payments_withdrawals", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "theoretical_cash", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "total_income", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "transfer_income_gross", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.datetime "validated_at"
    t.jsonb "validation_data", default: {}, null: false
    t.index ["closure_date"], name: "index_turn_closures_on_closure_date"
    t.index ["closure_number"], name: "index_turn_closures_on_closure_number", unique: true
    t.index ["has_errors"], name: "index_turn_closures_on_has_errors"
    t.index ["has_warnings"], name: "index_turn_closures_on_has_warnings"
    t.index ["user_id"], name: "index_turn_closures_on_user_id"
    t.index ["validated_at"], name: "index_turn_closures_on_validated_at"
    t.index ["validation_data"], name: "index_turn_closures_on_validation_data", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "admin"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "credit_cards", "users"
  add_foreign_key "credit_purchases", "credit_cards"
  add_foreign_key "credit_purchases", "users"
  add_foreign_key "debt_payments", "credit_purchases"
  add_foreign_key "expenses", "payment_methods"
  add_foreign_key "expenses", "users"
  add_foreign_key "loan_payments", "loans"
  add_foreign_key "loans", "lenders"
  add_foreign_key "loyverse_payment_mappings", "payment_methods"
  add_foreign_key "loyverse_receipts", "loyverse_shifts"
  add_foreign_key "loyverse_receipts", "turn_closures"
  add_foreign_key "loyverse_shifts", "turn_closures"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "reimbursement_expenses", "expenses", on_delete: :cascade
  add_foreign_key "reimbursement_expenses", "reimbursements", on_delete: :cascade
  add_foreign_key "reimbursements", "accounts", column: "from_account_id"
  add_foreign_key "reimbursements", "users"
  add_foreign_key "reimbursements", "users", column: "to_user_id"
  add_foreign_key "turn_closures", "users"
end
