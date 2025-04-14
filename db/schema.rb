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

ActiveRecord::Schema[8.0].define(version: 2025_04_07_221035) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_lead_sources", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_account_lead_sources_on_name", unique: true
  end

  create_table "accounts", force: :cascade do |t|
    t.bigint "parent_id"
    t.bigint "owner_id", null: false
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
    t.datetime "last_activity_at"
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

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "occurring_at", null: false
    t.bigint "type_id", null: false
    t.text "title", null: false
    t.boolean "complete", default: false, null: false
    t.string "logged_to_type", null: false
    t.bigint "logged_to_id", null: false
    t.bigint "created_by_id"
    t.bigint "last_updated_by_id"
    t.bigint "assigned_to_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_activities_on_account_id"
    t.index ["assigned_to_id"], name: "index_activities_on_assigned_to_id"
    t.index ["created_by_id"], name: "index_activities_on_created_by_id"
    t.index ["last_updated_by_id"], name: "index_activities_on_last_updated_by_id"
    t.index ["logged_to_type", "logged_to_id"], name: "index_activities_on_logged_to"
    t.index ["type_id"], name: "index_activities_on_type_id"
  end

  create_table "activities_contacts", force: :cascade do |t|
    t.bigint "activity_id", null: false
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_activities_contacts_on_activity_id"
    t.index ["contact_id"], name: "index_activities_contacts_on_contact_id"
  end

  create_table "activity_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_activity_types_on_name", unique: true
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

  create_table "contacts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "email_address", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.bigint "phone_number_id"
    t.datetime "last_activity_at"
    t.bigint "lead_source_id"
    t.bigint "address_id"
    t.bigint "owner_id"
    t.string "job_title"
    t.bigint "created_by_id"
    t.bigint "last_updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_contacts_on_account_id"
    t.index ["address_id"], name: "index_contacts_on_address_id"
    t.index ["created_by_id"], name: "index_contacts_on_created_by_id"
    t.index ["last_updated_by_id"], name: "index_contacts_on_last_updated_by_id"
    t.index ["lead_source_id"], name: "index_contacts_on_lead_source_id"
    t.index ["owner_id"], name: "index_contacts_on_owner_id"
    t.index ["phone_number_id"], name: "index_contacts_on_phone_number_id"
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
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "accounts"
  add_foreign_key "activities", "activity_types", column: "type_id"
  add_foreign_key "activities", "users", column: "assigned_to_id"
  add_foreign_key "activities", "users", column: "created_by_id"
  add_foreign_key "activities", "users", column: "last_updated_by_id"
  add_foreign_key "activities_contacts", "activities"
  add_foreign_key "activities_contacts", "contacts"
  add_foreign_key "addresses", "countries"
  add_foreign_key "addresses", "state_regions"
  add_foreign_key "contacts", "account_lead_sources", column: "lead_source_id"
  add_foreign_key "contacts", "accounts"
  add_foreign_key "contacts", "addresses"
  add_foreign_key "contacts", "users", column: "created_by_id"
  add_foreign_key "contacts", "users", column: "last_updated_by_id"
  add_foreign_key "contacts", "users", column: "owner_id"
  add_foreign_key "phone_numbers", "countries"
  add_foreign_key "sessions", "users"
  add_foreign_key "state_regions", "countries"
  add_foreign_key "state_regions", "state_region_types"
  add_foreign_key "users", "users", column: "created_by_id"
  add_foreign_key "users", "users", column: "last_updated_by_id"
end
