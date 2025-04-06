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

ActiveRecord::Schema[8.0].define(version: 2025_04_06_170558) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_lead_sources", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_account_lead_sources_on_name", unique: true
  end

  create_table "accounts", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.bigint "billing_address_id"
    t.bigint "shipping_address_id"
    t.bigint "phone_number_id"
    t.text "description"
    t.integer "annual_revenue"
    t.integer "number_of_employees"
    t.bigint "industry_id"
    t.string "website"
    t.date "incorporation_date"
    t.bigint "account_source_id"
    t.datetime "last_activity_time"
    t.bigint "created_by_id"
    t.bigint "last_updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_source_id"], name: "index_accounts_on_account_source_id"
    t.index ["billing_address_id"], name: "index_accounts_on_billing_address_id"
    t.index ["created_by_id"], name: "index_accounts_on_created_by_id"
    t.index ["industry_id"], name: "index_accounts_on_industry_id"
    t.index ["last_updated_by_id"], name: "index_accounts_on_last_updated_by_id"
    t.index ["owner_id"], name: "index_accounts_on_owner_id"
    t.index ["parent_id"], name: "index_accounts_on_parent_id"
    t.index ["phone_number_id"], name: "index_accounts_on_phone_number_id"
    t.index ["shipping_address_id"], name: "index_accounts_on_shipping_address_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.text "street"
    t.text "city"
    t.bigint "state_region_id"
    t.bigint "country_id", null: false
    t.text "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_addresses_on_country_id"
    t.index ["state_region_id"], name: "index_addresses_on_state_region_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "alpha_2", null: false
    t.string "alpha_3", null: false
    t.string "country_code", null: false
    t.string "iso_3166__2", null: false
    t.string "region"
    t.string "sub_region"
    t.string "intermediate_region"
    t.string "region_code"
    t.string "sub_region_code"
    t.string "intermediate_region_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alpha_2"], name: "index_countries_on_alpha_2", unique: true
    t.index ["alpha_3"], name: "index_countries_on_alpha_3", unique: true
    t.index ["country_code"], name: "index_countries_on_country_code", unique: true
    t.index ["iso_3166__2"], name: "index_countries_on_iso_3166__2", unique: true
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "industries", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_industries_on_code", unique: true
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.bigint "country_id"
    t.string "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_phone_numbers_on_country_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "state_region_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "state_regions", force: :cascade do |t|
    t.string "country_short_code", null: false
    t.bigint "country_id", null: false
    t.string "name"
    t.bigint "state_region_type_id"
    t.string "alpha_code", null: false
    t.string "numeric_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_state_regions_on_country_id"
    t.index ["state_region_type_id"], name: "index_state_regions_on_state_region_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "job_title"
    t.bigint "created_by_id"
    t.bigint "last_updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.index ["created_by_id"], name: "index_users_on_created_by_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["last_updated_by_id"], name: "index_users_on_last_updated_by_id"
  end

  add_foreign_key "accounts", "account_lead_sources", column: "account_source_id"
  add_foreign_key "accounts", "accounts", column: "parent_id"
  add_foreign_key "accounts", "addresses", column: "billing_address_id"
  add_foreign_key "accounts", "addresses", column: "shipping_address_id"
  add_foreign_key "accounts", "industries"
  add_foreign_key "accounts", "phone_numbers"
  add_foreign_key "accounts", "users", column: "created_by_id"
  add_foreign_key "accounts", "users", column: "last_updated_by_id"
  add_foreign_key "accounts", "users", column: "owner_id"
  add_foreign_key "addresses", "countries"
  add_foreign_key "addresses", "state_regions"
  add_foreign_key "phone_numbers", "countries"
  add_foreign_key "sessions", "users"
  add_foreign_key "state_regions", "countries"
  add_foreign_key "state_regions", "state_region_types"
  add_foreign_key "users", "users", column: "created_by_id"
  add_foreign_key "users", "users", column: "last_updated_by_id"
end
