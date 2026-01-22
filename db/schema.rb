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

ActiveRecord::Schema[7.2].define(version: 2026_01_21_111351) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "ai_verifications", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.integer "status"
    t.decimal "confidence"
    t.text "reason"
    t.jsonb "raw_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_ai_verifications_on_listing_id"
  end

  create_table "bids", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "user_id", null: false
    t.decimal "amount", precision: 12, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "amount"], name: "index_bids_on_listing_id_and_amount"
    t.index ["listing_id"], name: "index_bids_on_listing_id"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "condition"
    t.text "seller_note"
    t.integer "status"
    t.text "ai_note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "start_price"
    t.datetime "published_at"
    t.decimal "reserve_price"
    t.decimal "bid_increment"
    t.datetime "auction_ends_at"
    t.decimal "buy_now_price", precision: 12
    t.bigint "reference_item_id"
    t.string "category"
    t.bigint "category_id"
    t.index ["category_id"], name: "index_listings_on_category_id"
    t.index ["published_at"], name: "index_listings_on_published_at"
    t.index ["reference_item_id"], name: "index_listings_on_reference_item_id"
    t.index ["status"], name: "index_listings_on_status"
    t.index ["user_id"], name: "index_listings_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.bigint "actor_id"
    t.integer "action", null: false
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.text "message", null: false
    t.string "url"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["recipient_id", "created_at"], name: "index_notifications_on_recipient_id_and_created_at"
    t.index ["recipient_id", "read_at"], name: "index_notifications_on_recipient_id_and_read_at"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "buyer_id", null: false
    t.decimal "price"
    t.integer "kind"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total"
    t.datetime "buyer_marked_paid_at"
    t.datetime "admin_confirmed_paid_at"
    t.string "recipient_name"
    t.string "recipient_phone"
    t.text "shipping_address"
    t.datetime "received_at"
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
    t.index ["listing_id"], name: "index_orders_on_listing_id", unique: true
  end

  create_table "otps", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "purpose"
    t.string "code_digest"
    t.datetime "expires_at"
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_otps_on_user_id"
  end

  create_table "reference_items", force: :cascade do |t|
    t.string "name"
    t.string "brand"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "system_settings", force: :cascade do |t|
    t.decimal "ai_threshold"
    t.decimal "commission_percent"
    t.decimal "min_bid_step"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "email_verified_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ai_verifications", "listings"
  add_foreign_key "bids", "listings"
  add_foreign_key "bids", "users"
  add_foreign_key "listings", "categories"
  add_foreign_key "listings", "reference_items"
  add_foreign_key "listings", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "orders", "listings"
  add_foreign_key "orders", "users", column: "buyer_id"
  add_foreign_key "otps", "users"
end
