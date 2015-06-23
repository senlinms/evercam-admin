# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150623163156) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "camera_shares", force: :cascade do |t|
    t.integer  "camera_id",             null: false
    t.integer  "user_id",               null: false
    t.integer  "sharer_id"
    t.string   "kind",       limit: 50, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "camera_shares", ["camera_id"], name: "index_camera_shares_on_camera_id", using: :btree
  add_index "camera_shares", ["user_id"], name: "index_camera_shares_on_user_id", using: :btree

  create_table "cameras", force: :cascade do |t|
    t.string   "exid",                            null: false
    t.integer  "user_id",                         null: false
    t.boolean  "is_public",                       null: false
    t.json     "config",                          null: false
    t.string   "name",                            null: false
    t.datetime "last_polled_at"
    t.boolean  "is_online"
    t.string   "timezone"
    t.datetime "last_online_at"
    t.text     "location"
    t.macaddr  "mac_address"
    t.integer  "vendor_model_id"
    t.boolean  "discoverable",    default: false, null: false
    t.binary   "preview"
    t.string   "thumbnail_url"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "iso3166_a2", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "snapshots", force: :cascade do |t|
    t.string   "notes"
    t.integer  "camera_id",                  null: false
    t.binary   "data",                       null: false
    t.boolean  "is_public",  default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "snapshots", ["camera_id"], name: "index_snapshots_on_camera_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "firstname",                          null: false
    t.string   "lastname",                           null: false
    t.string   "username",                           null: false
    t.string   "password",                           null: false
    t.integer  "country_id"
    t.datetime "confirmed_at"
    t.string   "email",                              null: false
    t.string   "reset_token"
    t.datetime "token_expires_at"
    t.string   "api_id"
    t.string   "api_key"
    t.boolean  "is_admin",           default: false, null: false
    t.string   "stripe_customer_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "users", ["country_id"], name: "index_users_on_country_id", using: :btree

  create_table "vendor_models", force: :cascade do |t|
    t.integer  "vendor_id"
    t.string   "name",                    null: false
    t.json     "config",                  null: false
    t.string   "exid",       default: "", null: false
    t.string   "jpg_url",    default: "", null: false
    t.string   "h264_url",   default: "", null: false
    t.string   "mjpg_url",   default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "vendor_models", ["vendor_id"], name: "index_vendor_models_on_vendor_id", using: :btree

  create_table "vendors", force: :cascade do |t|
    t.string   "exid",       null: false
    t.string   "name",       null: false
    t.string   "known_macs", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "camera_shares", "cameras"
  add_foreign_key "camera_shares", "users"
  add_foreign_key "users", "countries"
  add_foreign_key "vendor_models", "vendors"
end
