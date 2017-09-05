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

ActiveRecord::Schema.define(version: 20170830110410) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "leaderships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
  end

  create_table "pay_scales", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label", null: false
  end

  create_table "regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "school_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label", null: false
  end

  create_table "schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.uuid "school_type_id"
    t.uuid "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id"], name: "index_schools_on_region_id"
    t.index ["school_type_id"], name: "index_schools_on_school_type_id"
  end

  create_table "subjects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "vacancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "job_title", null: false
    t.string "slug", null: false
    t.string "headline", null: false
    t.text "job_description", null: false
    t.integer "minimum_salary", null: false
    t.integer "maximum_salary"
    t.text "benefits"
    t.integer "working_pattern"
    t.float "full_time_equivalent"
    t.integer "weekly_hours"
    t.date "starts_on"
    t.date "ends_on"
    t.uuid "subject_id"
    t.uuid "pay_scale_id"
    t.uuid "leadership_id"
    t.text "essential_requirements", null: false
    t.text "education"
    t.text "qualifications"
    t.text "experience"
    t.string "contact_email"
    t.string "reference"
    t.integer "status"
    t.date "expires_on"
    t.date "publish_on"
    t.uuid "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_on"], name: "index_vacancies_on_expires_on"
    t.index ["leadership_id"], name: "index_vacancies_on_leadership_id"
    t.index ["pay_scale_id"], name: "index_vacancies_on_pay_scale_id"
    t.index ["school_id"], name: "index_vacancies_on_school_id"
    t.index ["subject_id"], name: "index_vacancies_on_subject_id"
  end

end
