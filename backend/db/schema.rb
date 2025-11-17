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

ActiveRecord::Schema[8.1].define(version: 2025_11_17_043346) do
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

  create_table "expenses", force: :cascade do |t|
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.date "expense_date", null: false
    t.string "payment_source", null: false
    t.string "provider"
    t.string "receipt_photo_url", limit: 500
    t.boolean "reimbursed", default: false, null: false
    t.boolean "requires_reimbursement", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["category"], name: "index_expenses_on_category"
    t.index ["expense_date"], name: "index_expenses_on_expense_date"
    t.index ["payment_source"], name: "index_expenses_on_payment_source"
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
    t.decimal "card_income", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "cash_collected", precision: 15, scale: 2, default: "0.0", null: false
    t.string "closed_by", null: false
    t.integer "closure_number", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.decimal "payments_withdrawals", precision: 15, scale: 2, default: "0.0", null: false
    t.date "report_date", null: false
    t.decimal "theoretical_cash", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "transfer_income", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["closure_number"], name: "index_turn_closures_on_closure_number", unique: true
    t.index ["report_date"], name: "index_turn_closures_on_report_date"
    t.index ["user_id"], name: "index_turn_closures_on_user_id"
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

  add_foreign_key "expenses", "users"
  add_foreign_key "reimbursement_expenses", "expenses", on_delete: :cascade
  add_foreign_key "reimbursement_expenses", "reimbursements", on_delete: :cascade
  add_foreign_key "reimbursements", "accounts", column: "from_account_id"
  add_foreign_key "reimbursements", "users"
  add_foreign_key "reimbursements", "users", column: "to_user_id"
  add_foreign_key "turn_closures", "users"
end
