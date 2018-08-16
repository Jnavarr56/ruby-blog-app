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

ActiveRecord::Schema.define(version: 2018_08_14_173719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password"
    t.date "dob"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "time_logged"
    t.string "verify_code"
    t.boolean "verified"
    t.string "update_code"
    t.string "new_first_name"
    t.string "new_last_name"
    t.string "new_email_name"
    t.string "new_passwords"
  end

  create_table "followers", force: :cascade do |t|
    t.integer "followed_user_id"
    t.integer "following_user_id"
  end

  create_table "hashtag_joins", force: :cascade do |t|
    t.integer "hashtag_id"
    t.integer "post_id"
  end

  create_table "hashtags", force: :cascade do |t|
    t.string "hashtag"
  end

  create_table "interact_joins", force: :cascade do |t|
    t.integer "post_id"
    t.integer "post_type_id"
    t.integer "interacting_user_id"
  end

  create_table "interacts", force: :cascade do |t|
    t.integer "post_id"
    t.string "interact_type"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "date_posted"
    t.string "content"
    t.string "type"
  end

end
