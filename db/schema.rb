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

ActiveRecord::Schema[7.0].define(version: 2022_07_20_141226) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "fuzzystrmatch"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "alert_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subscription_id"
    t.date "run_on"
    t.string "job_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", default: 0
    t.index ["subscription_id"], name: "index_alert_runs_on_subscription_id"
  end

  create_table "emergency_login_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "not_valid_after", precision: nil, null: false
    t.uuid "publisher_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["publisher_id"], name: "index_emergency_login_keys_on_publisher_id"
  end

  create_table "employments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "salary", default: "", null: false
    t.string "subjects", default: "", null: false
    t.string "current_role", default: "", null: false
    t.date "started_on"
    t.date "ended_on"
    t.uuid "job_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "employment_type", default: 0
    t.text "reason_for_break", default: ""
    t.text "organisation_ciphertext"
    t.text "job_title_ciphertext"
    t.text "main_duties_ciphertext"
    t.index ["job_application_id"], name: "index_employments_on_job_application_id"
  end

  create_table "equal_opportunities_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vacancy_id", null: false
    t.integer "total_submissions", default: 0, null: false
    t.integer "disability_no", default: 0, null: false
    t.integer "disability_prefer_not_to_say", default: 0, null: false
    t.integer "disability_yes", default: 0, null: false
    t.integer "gender_man", default: 0, null: false
    t.integer "gender_other", default: 0, null: false
    t.integer "gender_prefer_not_to_say", default: 0, null: false
    t.integer "gender_woman", default: 0, null: false
    t.string "gender_other_descriptions", default: [], null: false, array: true
    t.integer "orientation_bisexual", default: 0, null: false
    t.integer "orientation_gay_or_lesbian", default: 0, null: false
    t.integer "orientation_heterosexual", default: 0, null: false
    t.integer "orientation_other", default: 0, null: false
    t.integer "orientation_prefer_not_to_say", default: 0, null: false
    t.string "orientation_other_descriptions", default: [], null: false, array: true
    t.integer "ethnicity_asian", default: 0, null: false
    t.integer "ethnicity_black", default: 0, null: false
    t.integer "ethnicity_mixed", default: 0, null: false
    t.integer "ethnicity_other", default: 0, null: false
    t.integer "ethnicity_prefer_not_to_say", default: 0, null: false
    t.integer "ethnicity_white", default: 0, null: false
    t.string "ethnicity_other_descriptions", default: [], null: false, array: true
    t.integer "religion_buddhist", default: 0, null: false
    t.integer "religion_christian", default: 0, null: false
    t.integer "religion_hindu", default: 0, null: false
    t.integer "religion_jewish", default: 0, null: false
    t.integer "religion_muslim", default: 0, null: false
    t.integer "religion_none", default: 0, null: false
    t.integer "religion_other", default: 0, null: false
    t.integer "religion_prefer_not_to_say", default: 0, null: false
    t.integer "religion_sikh", default: 0, null: false
    t.string "religion_other_descriptions", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "age_under_twenty_five", default: 0, null: false
    t.integer "age_twenty_five_to_twenty_nine", default: 0, null: false
    t.integer "age_prefer_not_to_say", default: 0, null: false
    t.integer "age_thirty_to_thirty_nine", default: 0, null: false
    t.integer "age_forty_to_forty_nine", default: 0, null: false
    t.integer "age_fifty_to_fifty_nine", default: 0, null: false
    t.integer "age_sixty_and_over", default: 0, null: false
    t.index ["vacancy_id"], name: "index_equal_opportunities_reports_on_vacancy_id"
  end

  create_table "feedbacks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "feedback_type"
    t.integer "rating"
    t.text "comment"
    t.float "recaptcha_score"
    t.boolean "relevant_to_user"
    t.jsonb "search_criteria"
    t.uuid "job_alert_vacancy_ids", array: true
    t.integer "unsubscribe_reason"
    t.text "other_unsubscribe_reason_comment"
    t.string "email"
    t.integer "user_participation_response"
    t.integer "visit_purpose"
    t.text "visit_purpose_comment"
    t.uuid "job_application_id"
    t.uuid "jobseeker_id"
    t.uuid "publisher_id"
    t.uuid "subscription_id"
    t.uuid "vacancy_id"
    t.integer "close_account_reason"
    t.text "close_account_reason_comment"
    t.string "category"
    t.index ["vacancy_id"], name: "index_feedbacks_on_vacancy_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.uuid "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "job_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "jobseeker_id"
    t.uuid "vacancy_id"
    t.integer "completed_steps", default: [], null: false, array: true
    t.datetime "submitted_at", precision: nil
    t.datetime "draft_at", precision: nil
    t.datetime "shortlisted_at", precision: nil
    t.datetime "unsuccessful_at", precision: nil
    t.datetime "withdrawn_at", precision: nil
    t.string "qualified_teacher_status", default: "", null: false
    t.string "qualified_teacher_status_year", default: "", null: false
    t.text "qualified_teacher_status_details", default: "", null: false
    t.string "statutory_induction_complete", default: "", null: false
    t.string "support_needed", default: "", null: false
    t.string "close_relationships", default: "", null: false
    t.string "right_to_work_in_uk", default: "", null: false
    t.string "gaps_in_employment", default: "", null: false
    t.string "disability", default: "", null: false
    t.string "gender", default: "", null: false
    t.string "gender_description", default: "", null: false
    t.string "orientation", default: "", null: false
    t.string "orientation_description", default: "", null: false
    t.string "ethnicity", default: "", null: false
    t.string "ethnicity_description", default: "", null: false
    t.string "religion", default: "", null: false
    t.string "religion_description", default: "", null: false
    t.datetime "reviewed_at", precision: nil
    t.string "country", default: "", null: false
    t.string "age", default: "", null: false
    t.string "email_address", default: "", null: false
    t.boolean "withdrawn_by_closing_account", default: false, null: false
    t.text "first_name_ciphertext"
    t.text "last_name_ciphertext"
    t.text "previous_names_ciphertext"
    t.text "street_address_ciphertext"
    t.text "city_ciphertext"
    t.text "postcode_ciphertext"
    t.text "phone_number_ciphertext"
    t.text "teacher_reference_number_ciphertext"
    t.text "national_insurance_number_ciphertext"
    t.text "personal_statement_ciphertext"
    t.text "support_needed_details_ciphertext"
    t.text "close_relationships_details_ciphertext"
    t.text "further_instructions_ciphertext"
    t.text "rejection_reasons_ciphertext"
    t.text "gaps_in_employment_details_ciphertext"
    t.integer "in_progress_steps", default: [], null: false, array: true
    t.boolean "employment_history_section_completed"
    t.boolean "qualifications_section_completed"
    t.index ["vacancy_id"], name: "index_job_applications_on_vacancy_id"
  end

  create_table "jobseekers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "account_closed_on"
    t.text "current_sign_in_ip_ciphertext"
    t.text "last_sign_in_ip_ciphertext"
    t.index ["confirmation_token"], name: "index_jobseekers_on_confirmation_token", unique: true
    t.index ["email"], name: "index_jobseekers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_jobseekers_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_jobseekers_on_unlock_token", unique: true
  end

  create_table "local_authority_publisher_schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "publisher_preference_id"
    t.uuid "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "location_polygons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "location_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.geography "area", limit: {:srid=>4326, :type=>"geometry", :geographic=>true}
    t.index ["area"], name: "index_location_polygons_on_area", using: :gist
    t.index ["name"], name: "index_location_polygons_on_name"
  end

  create_table "markers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vacancy_id", null: false
    t.uuid "organisation_id", null: false
    t.geography "geopoint", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["geopoint"], name: "index_markers_on_geopoint", using: :gist
    t.index ["organisation_id"], name: "index_markers_on_organisation_id"
    t.index ["vacancy_id"], name: "index_markers_on_vacancy_id"
  end

  create_table "notes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "content"
    t.uuid "publisher_id", null: false
    t.uuid "job_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_application_id"], name: "index_notes_on_job_application_id"
    t.index ["publisher_id"], name: "index_notes_on_publisher_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "recipient_type", null: false
    t.uuid "recipient_id", null: false
    t.string "type", null: false
    t.jsonb "params"
    t.datetime "read_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "organisation_publisher_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organisation_id"
    t.uuid "publisher_preference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organisation_publishers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organisation_id"
    t.uuid "publisher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organisation_vacancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organisation_id"
    t.uuid "vacancy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["organisation_id", "vacancy_id"], name: "index_organisation_vacancies_on_organisation_id_and_vacancy_id", unique: true
    t.index ["vacancy_id", "organisation_id"], name: "index_organisation_vacancies_on_vacancy_id_and_organisation_id", unique: true
  end

  create_table "organisations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.text "description"
    t.string "urn"
    t.string "uid"
    t.integer "phase"
    t.string "url"
    t.integer "minimum_age"
    t.integer "maximum_age"
    t.string "address"
    t.string "town"
    t.string "county"
    t.string "postcode"
    t.text "locality"
    t.text "address3"
    t.json "gias_data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "readable_phases", array: true
    t.string "url_override"
    t.string "region"
    t.string "detailed_school_type"
    t.string "school_type"
    t.string "local_authority_code"
    t.string "group_type"
    t.string "local_authority_within"
    t.string "establishment_status"
    t.geography "geopoint", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.text "gias_data_hash"
    t.string "slug"
    t.index ["geopoint"], name: "index_organisations_on_geopoint", using: :gist
    t.index ["local_authority_code"], name: "index_organisations_on_local_authority_code", unique: true
    t.index ["slug"], name: "index_organisations_on_slug", unique: true
    t.index ["type"], name: "index_organisations_on_type"
    t.index ["uid"], name: "index_organisations_on_uid", unique: true
    t.index ["urn"], name: "index_organisations_on_urn", unique: true
  end

  create_table "publisher_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "publisher_id"
    t.uuid "organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["organisation_id"], name: "index_publisher_preferences_on_organisation_id"
    t.index ["publisher_id"], name: "index_publisher_preferences_on_publisher_id"
  end

  create_table "publishers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "oid"
    t.datetime "accepted_terms_at", precision: nil
    t.string "email"
    t.datetime "last_activity_at", precision: nil
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "family_name_ciphertext"
    t.text "given_name_ciphertext"
    t.datetime "dismissed_new_features_page_at", precision: nil
    t.datetime "unsubscribed_from_expired_vacancy_prompt_at", precision: nil
    t.index ["email"], name: "index_publishers_on_email"
    t.index ["oid"], name: "index_publishers_on_oid", unique: true
  end

  create_table "qualification_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "qualification_id", null: false
    t.string "subject", null: false
    t.string "grade", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qualification_id"], name: "index_qualification_results_on_qualification_id"
  end

  create_table "qualifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category"
    t.boolean "finished_studying"
    t.string "grade", default: "", null: false
    t.string "institution", default: "", null: false
    t.string "name", default: "", null: false
    t.string "subject", default: "", null: false
    t.integer "year"
    t.uuid "job_application_id", null: false
    t.text "finished_studying_details_ciphertext"
    t.index ["job_application_id"], name: "index_qualifications_on_job_application_id"
  end

  create_table "references", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "relationship", default: "", null: false
    t.uuid "job_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name_ciphertext"
    t.text "job_title_ciphertext"
    t.text "organisation_ciphertext"
    t.text "email_ciphertext"
    t.text "phone_number_ciphertext"
    t.index ["job_application_id"], name: "index_references_on_job_application_id"
  end

  create_table "saved_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "jobseeker_id"
    t.uuid "vacancy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jobseeker_id"], name: "index_saved_jobs_on_jobseeker_id"
  end

  create_table "school_group_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id"
    t.uuid "school_group_id"
    t.boolean "do_not_delete"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["school_group_id", "school_id"], name: "index_school_group_memberships_on_school_group_id_and_school_id"
    t.index ["school_id", "school_group_id"], name: "index_school_group_memberships_on_school_id_and_school_group_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.integer "frequency"
    t.jsonb "search_criteria"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.float "recaptcha_score"
    t.boolean "active", default: true
    t.datetime "unsubscribed_at", precision: nil
    t.index ["email"], name: "index_subscriptions_on_email"
  end

  create_table "support_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "oid"
    t.string "email"
    t.string "given_name"
    t.string "family_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["oid"], name: "index_support_users_on_oid"
  end

  create_table "vacancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "job_title"
    t.string "slug", null: false
    t.text "job_advert"
    t.text "benefits"
    t.date "starts_on"
    t.string "contact_email"
    t.integer "status"
    t.date "publish_on"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "application_link"
    t.integer "working_patterns", array: true
    t.integer "listed_elsewhere"
    t.integer "hired_status"
    t.datetime "stats_updated_at", precision: nil
    t.uuid "publisher_id"
    t.datetime "expires_at", precision: nil
    t.string "salary"
    t.text "about_school"
    t.string "subjects", array: true
    t.text "school_visits"
    t.text "how_to_apply"
    t.integer "job_location"
    t.string "readable_job_location"
    t.integer "job_roles", array: true
    t.string "contact_number"
    t.uuid "publisher_organisation_id"
    t.boolean "starts_asap"
    t.integer "contract_type"
    t.string "fixed_term_contract_duration"
    t.text "personal_statement_guidance"
    t.boolean "enable_job_applications"
    t.string "completed_steps", default: [], null: false, array: true
    t.string "actual_salary"
    t.text "working_patterns_details"
    t.integer "phase"
    t.integer "key_stages", array: true
    t.geography "geolocation", limit: {:srid=>4326, :type=>"geometry", :geographic=>true}
    t.string "readable_phases", default: [], array: true
    t.tsvector "searchable_content"
    t.boolean "google_index_removed", default: false
    t.string "parental_leave_cover_contract_duration"
    t.datetime "expired_vacancy_feedback_email_sent_at", precision: nil
    t.string "external_source"
    t.string "external_reference"
    t.string "external_advert_url"
    t.integer "ect_status"
    t.integer "job_role"
    t.index ["expires_at"], name: "index_vacancies_on_expires_at"
    t.index ["geolocation"], name: "index_vacancies_on_geolocation", using: :gist
    t.index ["publish_on"], name: "index_vacancies_on_publish_on"
    t.index ["publisher_id"], name: "index_vacancies_on_publisher_id"
    t.index ["publisher_organisation_id"], name: "index_vacancies_on_publisher_organisation_id"
    t.index ["searchable_content"], name: "index_vacancies_on_searchable_content", using: :gin
    t.index ["slug"], name: "index_vacancies_on_slug"
    t.index ["status"], name: "index_vacancies_on_status"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.uuid "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
    t.jsonb "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "emergency_login_keys", "publishers"
  add_foreign_key "employments", "job_applications"
  add_foreign_key "equal_opportunities_reports", "vacancies"
  add_foreign_key "job_applications", "vacancies"
  add_foreign_key "markers", "organisations"
  add_foreign_key "markers", "vacancies"
  add_foreign_key "notes", "job_applications"
  add_foreign_key "notes", "publishers"
  add_foreign_key "publisher_preferences", "publishers"
  add_foreign_key "qualification_results", "qualifications"
  add_foreign_key "qualifications", "job_applications"
  add_foreign_key "references", "job_applications"
  add_foreign_key "saved_jobs", "jobseekers"
  add_foreign_key "vacancies", "organisations", column: "publisher_organisation_id"
  add_foreign_key "vacancies", "publishers"
end
