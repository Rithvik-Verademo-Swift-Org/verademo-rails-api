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

ActiveRecord::Schema[7.0].define(version: 2024_01_01_000001) do
  create_table "blabs", primary_key: "blabid", force: :cascade do |t|
    t.string "blabber", limit: 100, null: false
    t.string "content", limit: 250
    t.datetime "timestamp", precision: nil
  end

  create_table "comments", primary_key: "commentid", force: :cascade do |t|
    t.integer "blabid", null: false
    t.string "blabber", limit: 100, null: false
    t.string "content", limit: 250
    t.datetime "timestamp", precision: nil
  end

  create_table "listeners", id: false, force: :cascade do |t|
    t.string "blabber", limit: 100, null: false
    t.string "listener", limit: 100, null: false
    t.string "status", limit: 20
  end

  create_table "users", primary_key: "username", id: { type: :string, limit: 100 }, force: :cascade do |t|
    t.string "password", limit: 100
    t.string "password_hint", limit: 100
    t.datetime "created_at", precision: nil
    t.datetime "last_login", precision: nil
    t.string "real_name", limit: 100
    t.string "blab_name", limit: 100
    t.string "totp_secret", limit: 100
  end

  create_table "users_history", primary_key: "eventid", force: :cascade do |t|
    t.string "blabber", limit: 100, null: false
    t.string "event", limit: 250
    t.datetime "timestamp", precision: nil
  end

end
