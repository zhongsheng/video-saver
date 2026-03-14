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

ActiveRecord::Schema[8.1].define(version: 2026_03_14_000000) do
  create_table "download_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.integer "video_asset_id", null: false
    t.index ["token"], name: "index_download_tokens_on_token", unique: true
    t.index ["video_asset_id"], name: "index_download_tokens_on_video_asset_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "last_seen_at"
    t.string "nickname"
    t.datetime "updated_at", null: false
    t.string "wechat_openid", null: false
    t.index ["wechat_openid"], name: "index_users_on_wechat_openid", unique: true
  end

  create_table "video_assets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.datetime "downloaded_at"
    t.integer "duration_ms"
    t.datetime "expires_at"
    t.text "failure_reason"
    t.bigint "file_size"
    t.string "source_message_id", null: false
    t.string "source_url", null: false
    t.string "status", default: "received", null: false
    t.string "storage_path"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["expires_at"], name: "index_video_assets_on_expires_at"
    t.index ["status"], name: "index_video_assets_on_status"
    t.index ["user_id"], name: "index_video_assets_on_user_id"
  end

  add_foreign_key "download_tokens", "video_assets"
  add_foreign_key "video_assets", "users"
end
