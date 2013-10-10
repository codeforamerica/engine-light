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

ActiveRecord::Schema.define(version: 20131010181135) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users_web_applications", force: true do |t|
    t.integer "user_id"
    t.integer "web_application_id"
  end

  add_index "users_web_applications", ["user_id", "web_application_id"], name: "index_users_web_applications_on_user_id_and_web_application_id", unique: true, using: :btree

  create_table "web_applications", force: true do |t|
    t.string   "name"
    t.string   "status_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.datetime "last_downtime_notification_at"
  end

  add_index "web_applications", ["name"], name: "index_web_applications_on_name", using: :btree
  add_index "web_applications", ["slug"], name: "index_web_applications_on_slug", using: :btree

end
