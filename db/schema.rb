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

ActiveRecord::Schema.define(version: 20170830110404) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "leaderships", force: :cascade do |t|
    t.string "title", null: false
  end

  create_table "pay_scales", force: :cascade do |t|
    t.string "label", null: false
  end

  create_table "regions", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "school_types", force: :cascade do |t|
    t.string "label", null: false
  end

  create_table "schools", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.string "urn", null: false
    t.string "address", null: false
    t.string "town", null: false
    t.string "county", null: false
    t.string "postcode", null: false
    t.integer "phase"
    t.string "url"
    t.integer "minimum_age"
    t.integer "maximum_age"
    t.bigint "school_type_id"
    t.bigint "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id"], name: "index_schools_on_region_id"
    t.index ["school_type_id"], name: "index_schools_on_school_type_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
  end

end
