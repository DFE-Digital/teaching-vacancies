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

ActiveRecord::Schema[8.0].define(version: 2026_01_22_161523) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "fuzzystrmatch"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "postgis"
  enable_extension "uuid-ossp"

  create_table "action_text_rich_texts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "body_ciphertext"
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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
    t.uuid "subscription_id", null: false
    t.date "run_on"
    t.string "job_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", default: 0
    t.index ["run_on"], name: "index_alert_runs_on_run_on"
    t.index ["subscription_id"], name: "index_alert_runs_on_subscription_id"
  end

  create_table "batchable_job_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_application_batch_id", null: false
    t.uuid "job_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_application_batch_id"], name: "index_batchable_job_applications_on_job_application_batch_id"
    t.index ["job_application_id"], name: "index_batchable_job_applications_on_job_application_id"
  end

  create_table "conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false, null: false
    t.datetime "last_message_at"
    t.boolean "has_unread_jobseeker_messages", default: false, null: false
    t.tsvector "searchable_content"
    t.index ["archived"], name: "index_conversations_on_archived"
    t.index ["job_application_id"], name: "index_conversations_on_job_application_id"
    t.index ["searchable_content"], name: "index_conversations_on_searchable_content", using: :gin
  end

  create_table "emergency_login_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "not_valid_after", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "owner_type", null: false
    t.uuid "owner_id", null: false
    t.index ["owner_type", "owner_id"], name: "index_emergency_login_keys_on_owner"
  end

  create_table "employments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "subjects", default: "", null: false
    t.date "started_on"
    t.date "ended_on"
    t.uuid "job_application_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "organisation_ciphertext"
    t.text "job_title_ciphertext"
    t.text "main_duties_ciphertext"
    t.integer "employment_type", default: 0
    t.text "reason_for_break", default: ""
    t.uuid "jobseeker_profile_id"
    t.text "reason_for_leaving"
    t.boolean "is_current_role", default: false, null: false
    t.index ["job_application_id"], name: "index_employments_on_job_application_id"
    t.index ["jobseeker_profile_id"], name: "index_employments_on_jobseeker_profile_id"
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
    t.index ["vacancy_id"], name: "index_equal_opportunities_reports_vacancy_id", unique: true
  end

  create_table "failed_imported_vacancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "import_errors", default: [], array: true
    t.string "source", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_reference"
    t.jsonb "vacancy"
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
    t.text "occupation"
    t.string "origin_path"
    t.text "job_found_unsubscribe_reason_comment"
    t.index ["job_application_id"], name: "index_feedbacks_job_application_id"
    t.index ["jobseeker_id"], name: "index_feedbacks_jobseeker_id"
    t.index ["publisher_id"], name: "index_feedbacks_publisher_id"
    t.index ["subscription_id"], name: "index_feedbacks_subscription_id"
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
    t.index ["sluggable_id", "sluggable_type"], name: "index_friendly_id_slugs_sluggable_id_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "job_application_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vacancy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vacancy_id"], name: "index_job_application_batches_on_vacancy_id"
  end

  create_table "job_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "jobseeker_id", null: false
    t.uuid "vacancy_id", null: false
    t.integer "completed_steps", default: [], null: false, array: true
    t.datetime "submitted_at", precision: nil
    t.datetime "draft_at", precision: nil
    t.datetime "shortlisted_at", precision: nil
    t.datetime "unsuccessful_at", precision: nil
    t.datetime "withdrawn_at", precision: nil
    t.string "qualified_teacher_status", default: "", null: false
    t.string "qualified_teacher_status_year", default: "", null: false
    t.text "qualified_teacher_status_details", default: "", null: false
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
    t.text "support_needed_details_ciphertext"
    t.text "close_relationships_details_ciphertext"
    t.text "further_instructions_ciphertext"
    t.text "rejection_reasons_ciphertext"
    t.text "gaps_in_employment_details_ciphertext"
    t.integer "in_progress_steps", default: [], null: false, array: true
    t.text "safeguarding_issue_details"
    t.integer "imported_steps", default: [], null: false, array: true
    t.datetime "interviewing_at"
    t.string "statutory_induction_complete_details"
    t.boolean "following_religion"
    t.integer "religious_reference_type"
    t.string "faith_ciphertext"
    t.string "place_of_worship_ciphertext"
    t.string "religious_referee_name_ciphertext"
    t.string "religious_referee_address_ciphertext"
    t.string "religious_referee_role_ciphertext"
    t.string "religious_referee_email_ciphertext"
    t.string "religious_referee_phone_ciphertext"
    t.string "baptism_address_ciphertext"
    t.string "baptism_date_ciphertext"
    t.string "ethos_and_aims_ciphertext"
    t.integer "working_patterns", array: true
    t.string "working_pattern_details"
    t.string "qts_age_range_and_subject"
    t.boolean "is_statutory_induction_complete"
    t.boolean "is_support_needed"
    t.boolean "has_close_relationships"
    t.boolean "has_right_to_work_in_uk"
    t.boolean "has_safeguarding_issue"
    t.boolean "notify_before_contact_referers"
    t.string "type"
    t.datetime "offered_at"
    t.datetime "declined_at"
    t.datetime "unsuccessful_interview_at"
    t.datetime "interview_feedback_received_at"
    t.boolean "interview_feedback_received"
    t.datetime "rejected_at"
    t.integer "online_checks", default: 1, null: false
    t.datetime "online_checks_updated_at"
    t.index ["jobseeker_id"], name: "index_job_applications_jobseeker_id"
    t.index ["vacancy_id"], name: "index_job_applications_on_vacancy_id"
  end

  create_table "job_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "roles", default: [], array: true
    t.string "phases", default: [], array: true
    t.string "key_stages", default: [], array: true
    t.string "subjects", default: [], array: true
    t.string "working_patterns", default: [], array: true
    t.json "completed_steps", default: {}
    t.boolean "builder_completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "jobseeker_profile_id", null: false
    t.string "working_pattern_details"
    t.index ["jobseeker_profile_id"], name: "index_job_preferences_jobseeker_profile_id", unique: true
  end

  create_table "job_preferences_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_preferences_id", null: false
    t.string "name", null: false
    t.integer "radius", null: false
    t.geography "area", limit: {srid: 4326, type: "geometry", geographic: true}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.geometry "uk_area", limit: {srid: 27700, type: "geometry"}, null: false
    t.index ["area"], name: "index_job_preferences_locations_on_area", using: :gist
    t.index ["job_preferences_id"], name: "index_job_preferences_locations_on_job_preferences_id"
    t.index ["uk_area"], name: "index_job_preferences_locations_on_uk_area", using: :gist
  end

  create_table "job_references", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "complete", default: false, null: false
    t.boolean "can_give_reference"
    t.boolean "is_reference_sharable"
    t.text "how_do_you_know_the_candidate_ciphertext"
    t.string "employment_start_date_ciphertext"
    t.boolean "currently_employed"
    t.text "reason_for_leaving_ciphertext"
    t.boolean "would_reemploy_current"
    t.text "would_reemploy_current_reason_ciphertext"
    t.boolean "would_reemploy_any"
    t.text "would_reemploy_any_reason_ciphertext"
    t.string "punctuality_ciphertext"
    t.string "working_relationships_ciphertext"
    t.string "customer_care_ciphertext"
    t.string "adapt_to_change_ciphertext"
    t.string "deal_with_conflict_ciphertext"
    t.string "prioritise_workload_ciphertext"
    t.string "team_working_ciphertext"
    t.string "communication_ciphertext"
    t.string "problem_solving_ciphertext"
    t.string "general_attitude_ciphertext"
    t.string "technical_competence_ciphertext"
    t.string "leadership_ciphertext"
    t.string "name"
    t.string "job_title"
    t.string "phone_number"
    t.string "email"
    t.string "organisation"
    t.string "under_investigation_ciphertext"
    t.string "warnings_ciphertext"
    t.string "allegations_ciphertext"
    t.string "not_fit_to_practice_ciphertext"
    t.string "able_to_undertake_role_ciphertext"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "under_investigation_details_ciphertext"
    t.string "warning_details_ciphertext"
    t.string "unable_to_undertake_reason_ciphertext"
    t.string "employment_end_date_ciphertext"
    t.string "not_provided_reason"
    t.uuid "reference_request_id", null: false
    t.index ["reference_request_id"], name: "index_job_references_on_reference_request_id", unique: true
  end

  create_table "jobseeker_profile_excluded_organisations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "jobseeker_profile_id", null: false
    t.uuid "organisation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jobseeker_profile_id"], name: "index_excluded_organisations_on_jobseeker_profile_id"
    t.index ["organisation_id"], name: "index_excluded_organisations_on_organisation_id"
  end

  create_table "jobseeker_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "jobseeker_id", null: false
    t.string "about_you"
    t.integer "qualified_teacher_status"
    t.string "qualified_teacher_status_year"
    t.boolean "active", default: false, null: false
    t.boolean "requested_hidden_profile"
    t.text "teacher_reference_number_ciphertext"
    t.string "statutory_induction_complete_details"
    t.string "qts_age_range_and_subject"
    t.text "qualified_teacher_status_details"
    t.boolean "is_statutory_induction_complete"
    t.index ["jobseeker_id"], name: "index_jobseeker_profiles_jobseeker_id", unique: true
  end

  create_table "jobseekers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "account_closed_on"
    t.text "current_sign_in_ip_ciphertext"
    t.string "govuk_one_login_id"
    t.text "last_sign_in_ip_ciphertext"
    t.string "account_merge_confirmation_code"
    t.datetime "account_merge_confirmation_code_generated_at"
    t.boolean "email_opt_out", default: false, null: false
    t.integer "email_opt_out_reason"
    t.text "email_opt_out_comment"
    t.index ["email"], name: "index_jobseekers_on_email", unique: true
    t.index ["govuk_one_login_id"], name: "index_jobseekers_on_govuk_one_login_id", unique: true
  end

  create_table "local_authority_publisher_schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "publisher_preference_id", null: false
    t.uuid "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_preference_id"], name: "index_local_authority_publisher_schools_publisher_preference_id"
  end

  create_table "location_polygons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "location_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.geography "area", limit: {srid: 4326, type: "geometry", geographic: true}
    t.geography "centroid", limit: {srid: 4326, type: "st_point", geographic: true}
    t.geometry "uk_area", limit: {srid: 27700, type: "geometry"}
    t.geometry "uk_centroid", limit: {srid: 27700, type: "st_point"}
    t.index ["area"], name: "index_location_polygons_on_area", using: :gist
    t.index ["centroid"], name: "index_location_polygons_on_centroid", using: :gist
    t.index ["name"], name: "index_location_polygons_on_name"
    t.index ["uk_area"], name: "index_location_polygons_on_uk_area", using: :gist
    t.index ["uk_centroid"], name: "index_location_polygons_on_uk_centroid", using: :gist
  end

  create_table "message_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "publisher_id", null: false
    t.integer "template_type", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id"], name: "index_message_templates_on_publisher_id"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sender_id", null: false
    t.uuid "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.boolean "read", default: false, null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
    t.index ["type", "created_at"], name: "index_messages_unread_on_type_created_at", where: "(read = false)"
  end

  create_table "notes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "content", null: false
    t.uuid "publisher_id", null: false
    t.uuid "job_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_notes_on_discarded_at"
    t.index ["job_application_id"], name: "index_notes_on_job_application_id"
    t.index ["publisher_id"], name: "index_notes_on_publisher_id"
  end

  create_table "noticed_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "record_type"
    t.uuid "record_id"
    t.jsonb "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notifications_count"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.uuid "event_id", null: false
    t.string "recipient_type", null: false
    t.uuid "recipient_id", null: false
    t.datetime "read_at", precision: nil
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "organisation_publisher_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organisation_id", null: false
    t.uuid "publisher_preference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_preference_id"], name: "index_organisation_publisher_preferences_publisher_preference_i"
  end

  create_table "organisation_publishers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organisation_id", null: false
    t.uuid "publisher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_organisation_publishers_organisation_id"
    t.index ["publisher_id"], name: "index_organisation_publishers_publisher_id"
  end

  create_table "organisation_vacancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organisation_id", null: false
    t.uuid "vacancy_id", null: false
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
    t.string "url_override"
    t.string "region"
    t.string "detailed_school_type"
    t.string "school_type"
    t.string "local_authority_code"
    t.string "group_type"
    t.string "local_authority_within"
    t.string "establishment_status"
    t.geography "geopoint", limit: {srid: 4326, type: "st_point", geographic: true}
    t.text "gias_data_hash"
    t.string "slug"
    t.string "email"
    t.string "safeguarding_information", default: "Our organisation is committed to safeguarding and promoting the welfare of children, young people and vulnerable adults. We expect all staff, volunteers and trustees to share this commitment.\n\nOur recruitment process follows the keeping children safe in education guidance.\n\nOffers of employment may be subject to the following checks (where relevant):\nchildcare disqualification\nDisclosure and Barring Service (DBS)\nmedical\nonline and social media\nprohibition from teaching\nright to work\nsatisfactory references\nsuitability to work with children\n\nYou must tell us about any unspent conviction, cautions, reprimands or warnings under the Rehabilitation of Offenders Act 1974 (Exceptions) Order 1975."
    t.tsvector "searchable_content"
    t.geometry "uk_geopoint", limit: {srid: 27700, type: "st_point"}
    t.index ["geopoint"], name: "index_organisations_on_geopoint", using: :gist
    t.index ["local_authority_code"], name: "index_organisations_on_local_authority_code", unique: true
    t.index ["searchable_content"], name: "index_organisations_on_searchable_content", using: :gin
    t.index ["slug"], name: "index_organisations_on_slug", unique: true
    t.index ["type"], name: "index_organisations_on_type"
    t.index ["uid"], name: "index_organisations_on_uid", unique: true
    t.index ["uk_geopoint"], name: "index_organisations_on_uk_geopoint", using: :gist
    t.index ["urn"], name: "index_organisations_on_urn", unique: true
  end

  create_table "personal_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "jobseeker_profile_id", null: false
    t.boolean "phone_number_provided"
    t.json "completed_steps", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "first_name_ciphertext"
    t.text "last_name_ciphertext"
    t.text "phone_number_ciphertext"
    t.boolean "has_right_to_work_in_uk"
    t.index ["jobseeker_profile_id"], name: "index_personal_details_jobseeker_profile_id", unique: true
  end

  create_table "pre_employment_check_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_application_id", null: false
    t.boolean "identity_check", default: false, null: false
    t.boolean "enhanced_dbs_check", default: false, null: false
    t.boolean "mental_and_physical_fitness", default: false, null: false
    t.boolean "right_to_work_in_uk", default: false, null: false
    t.boolean "professional_qualifications", default: false, null: false
    t.boolean "childrens_barred_list", default: false, null: false
    t.boolean "overseas_checks", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_application_id"], name: "index_pre_employment_check_sets_on_job_application_id", unique: true
  end

  create_table "professional_body_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "membership_type"
    t.string "membership_number"
    t.integer "year_membership_obtained"
    t.boolean "exam_taken", default: false, null: false
    t.uuid "jobseeker_profile_id"
    t.uuid "job_application_id"
    t.index ["job_application_id"], name: "index_professional_body_memberships_on_job_application_id"
    t.index ["jobseeker_profile_id"], name: "index_professional_body_memberships_on_jobseeker_profile_id"
  end

  create_table "publisher_ats_api_clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "api_key", null: false
    t.datetime "last_rotated_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publisher_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "publisher_id", null: false
    t.uuid "organisation_id", null: false
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
    t.boolean "acknowledged_candidate_profiles_interstitial", default: false, null: false
    t.boolean "email_opt_out", default: false, null: false
    t.index ["email"], name: "index_publishers_on_email"
    t.index ["oid"], name: "index_publishers_on_oid", unique: true
  end

  create_table "qualification_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "qualification_id", null: false
    t.string "subject", null: false
    t.string "grade", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "awarding_body"
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
    t.uuid "job_application_id"
    t.text "finished_studying_details_ciphertext"
    t.uuid "jobseeker_profile_id"
    t.string "awarding_body"
    t.integer "month"
    t.index ["job_application_id"], name: "index_qualifications_on_job_application_id"
    t.index ["jobseeker_profile_id"], name: "index_qualifications_on_jobseeker_profile_id"
  end

  create_table "reference_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "reference_id", null: false
    t.uuid "token"
    t.integer "status", null: false
    t.boolean "marked_as_complete", default: false, null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reminder_sent", default: false, null: false
    t.index ["reference_id"], name: "index_reference_requests_on_reference_id", unique: true
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
    t.boolean "is_most_recent_employer"
    t.index ["job_application_id"], name: "index_references_on_job_application_id"
  end

  create_table "religious_reference_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_application_id", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_application_id"], name: "index_religious_reference_requests_on_job_application_id", unique: true
  end

  create_table "saved_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "jobseeker_id", null: false
    t.uuid "vacancy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jobseeker_id"], name: "index_saved_jobs_on_jobseeker_id"
    t.index ["vacancy_id"], name: "index_saved_jobs_vacancy_id"
  end

  create_table "school_group_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id", null: false
    t.uuid "school_group_id", null: false
    t.boolean "do_not_delete"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["school_group_id", "school_id"], name: "index_school_group_memberships_on_school_group_id_and_school_id"
    t.index ["school_id", "school_group_id"], name: "index_school_group_memberships_on_school_id_and_school_group_id", unique: true
  end

  create_table "self_disclosure_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "job_application_id", null: false
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "marked_as_complete", default: false, null: false
    t.index ["job_application_id"], name: "index_self_disclosure_requests_on_job_application_id", unique: true
  end

  create_table "self_disclosures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name_ciphertext"
    t.string "previous_names_ciphertext"
    t.string "address_line_1_ciphertext"
    t.string "address_line_2_ciphertext"
    t.string "city_ciphertext"
    t.string "country_ciphertext"
    t.string "postcode_ciphertext"
    t.string "phone_number_ciphertext"
    t.string "date_of_birth_ciphertext"
    t.string "has_unspent_convictions_ciphertext"
    t.string "has_spent_convictions_ciphertext"
    t.string "is_barred_ciphertext"
    t.string "has_been_referred_ciphertext"
    t.string "is_known_to_children_services_ciphertext"
    t.string "has_been_dismissed_ciphertext"
    t.string "has_been_disciplined_ciphertext"
    t.string "has_been_disciplined_by_regulatory_body_ciphertext"
    t.string "agreed_for_processing_ciphertext"
    t.string "agreed_for_criminal_record_ciphertext"
    t.string "agreed_for_organisation_update_ciphertext"
    t.string "agreed_for_information_sharing_ciphertext"
    t.uuid "self_disclosure_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "true_and_complete_ciphertext"
    t.index ["self_disclosure_request_id"], name: "index_self_disclosures_on_self_disclosure_request_id", unique: true
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
    t.datetime "unsubscribed_at", precision: nil
    t.geometry "area", limit: {srid: 4326, type: "geometry"}
    t.geometry "geopoint", limit: {srid: 4326, type: "geometry"}
    t.integer "radius_in_metres"
    t.geometry "uk_geopoint", limit: {srid: 27700, type: "st_point"}
    t.geometry "uk_area", limit: {srid: 27700, type: "geometry"}
    t.datetime "deletion_warning_email_sent_at"
    t.index ["area"], name: "index_subscriptions_on_area", using: :gist
    t.index ["email"], name: "index_subscriptions_on_email"
    t.index ["geopoint"], name: "index_subscriptions_on_geopoint", using: :gist
    t.index ["uk_area"], name: "index_subscriptions_on_uk_area", using: :gist
    t.index ["uk_geopoint"], name: "index_subscriptions_on_uk_geopoint", using: :gist
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

  create_table "training_and_cpds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "provider"
    t.string "grade"
    t.string "year_awarded"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "jobseeker_profile_id"
    t.uuid "job_application_id"
    t.string "course_length"
    t.index ["job_application_id"], name: "index_training_and_cpds_on_job_application_id"
    t.index ["jobseeker_profile_id"], name: "index_training_and_cpds_on_jobseeker_profile_id"
  end

  create_table "vacancies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "job_title"
    t.string "slug", null: false
    t.text "job_advert"
    t.text "benefits_details"
    t.date "starts_on"
    t.string "contact_email"
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
    t.integer "job_location"
    t.string "readable_job_location"
    t.integer "job_roles", array: true
    t.string "contact_number"
    t.uuid "publisher_organisation_id"
    t.boolean "starts_asap"
    t.integer "contract_type"
    t.string "fixed_term_contract_duration"
    t.boolean "enable_job_applications"
    t.string "completed_steps", default: [], null: false, array: true
    t.string "actual_salary"
    t.text "working_patterns_details"
    t.integer "key_stages", array: true
    t.geography "geolocation", limit: {srid: 4326, type: "geometry", geographic: true}
    t.string "readable_phases", default: [], array: true
    t.tsvector "searchable_content"
    t.boolean "google_index_removed", default: false
    t.string "parental_leave_cover_contract_duration"
    t.datetime "expired_vacancy_feedback_email_sent_at", precision: nil
    t.string "external_source"
    t.string "external_reference"
    t.string "external_advert_url"
    t.integer "ect_status"
    t.string "pay_scale"
    t.boolean "benefits"
    t.text "full_time_details"
    t.text "part_time_details"
    t.integer "phases", array: true
    t.integer "start_date_type"
    t.date "earliest_start_date"
    t.date "latest_start_date"
    t.text "other_start_date_details"
    t.integer "receive_applications"
    t.string "application_email"
    t.boolean "school_visits"
    t.boolean "contact_number_provided"
    t.string "skills_and_experience"
    t.string "school_offer"
    t.boolean "further_details_provided"
    t.string "further_details"
    t.boolean "include_additional_documents"
    t.boolean "visa_sponsorship_available"
    t.boolean "is_parental_leave_cover"
    t.string "hourly_rate"
    t.boolean "is_job_share"
    t.string "flexi_working"
    t.integer "extension_reason"
    t.string "other_extension_reason_details"
    t.uuid "publisher_ats_api_client_id"
    t.integer "religion_type"
    t.boolean "flexi_working_details_provided"
    t.datetime "discarded_at"
    t.string "type", null: false
    t.boolean "anonymise_applications", default: false
    t.geometry "uk_geolocation", limit: {srid: 27700, type: "geometry"}
    t.index ["contact_email"], name: "index_vacancies_on_contact_email"
    t.index ["discarded_at"], name: "index_vacancies_on_discarded_at"
    t.index ["expires_at"], name: "index_vacancies_on_expires_at"
    t.index ["external_reference", "publisher_ats_api_client_id"], name: "index_kept_unique_vacancies_on_external_ref_and_client_id", unique: true, where: "(discarded_at IS NULL)"
    t.index ["external_source", "external_reference"], name: "index_vacancies_on_external_source_and_external_reference"
    t.index ["geolocation", "expires_at", "publish_on"], name: "index_vacancies_on_geolocation_and_expires_at_and_publish_on", using: :gist
    t.index ["publish_on"], name: "index_vacancies_on_publish_on"
    t.index ["publisher_ats_api_client_id"], name: "index_vacancies_on_publisher_ats_api_client_id"
    t.index ["publisher_id"], name: "index_vacancies_on_publisher_id"
    t.index ["publisher_organisation_id"], name: "index_vacancies_on_publisher_organisation_id"
    t.index ["searchable_content"], name: "index_vacancies_on_searchable_content", using: :gin
    t.index ["slug"], name: "index_vacancies_on_slug"
    t.index ["type"], name: "index_vacancies_on_type"
    t.index ["uk_geolocation"], name: "index_vacancies_on_uk_geolocation", using: :gist
  end

  create_table "vacancy_analytics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vacancy_id", null: false
    t.jsonb "referrer_counts", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referrer_counts"], name: "index_vacancy_analytics_on_referrer_counts", using: :gin
    t.index ["vacancy_id"], name: "index_vacancy_analytics_on_vacancy_id", unique: true
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
  add_foreign_key "alert_runs", "subscriptions"
  add_foreign_key "batchable_job_applications", "job_application_batches"
  add_foreign_key "batchable_job_applications", "job_applications"
  add_foreign_key "conversations", "job_applications"
  add_foreign_key "employments", "job_applications"
  add_foreign_key "employments", "jobseeker_profiles"
  add_foreign_key "equal_opportunities_reports", "vacancies"
  add_foreign_key "feedbacks", "job_applications"
  add_foreign_key "feedbacks", "jobseekers"
  add_foreign_key "feedbacks", "publishers"
  add_foreign_key "feedbacks", "subscriptions"
  add_foreign_key "feedbacks", "vacancies"
  add_foreign_key "job_application_batches", "vacancies"
  add_foreign_key "job_applications", "jobseekers"
  add_foreign_key "job_applications", "vacancies"
  add_foreign_key "job_preferences", "jobseeker_profiles"
  add_foreign_key "job_preferences_locations", "job_preferences", column: "job_preferences_id"
  add_foreign_key "job_references", "reference_requests"
  add_foreign_key "jobseeker_profile_excluded_organisations", "jobseeker_profiles"
  add_foreign_key "jobseeker_profile_excluded_organisations", "organisations"
  add_foreign_key "jobseeker_profiles", "jobseekers"
  add_foreign_key "local_authority_publisher_schools", "organisations", column: "school_id"
  add_foreign_key "local_authority_publisher_schools", "publisher_preferences"
  add_foreign_key "message_templates", "publishers"
  add_foreign_key "messages", "conversations"
  add_foreign_key "notes", "job_applications"
  add_foreign_key "notes", "publishers"
  add_foreign_key "organisation_publisher_preferences", "organisations"
  add_foreign_key "organisation_publisher_preferences", "publisher_preferences"
  add_foreign_key "organisation_publishers", "organisations"
  add_foreign_key "organisation_publishers", "publishers"
  add_foreign_key "organisation_vacancies", "organisations"
  add_foreign_key "organisation_vacancies", "vacancies"
  add_foreign_key "personal_details", "jobseeker_profiles"
  add_foreign_key "pre_employment_check_sets", "job_applications"
  add_foreign_key "professional_body_memberships", "job_applications"
  add_foreign_key "professional_body_memberships", "jobseeker_profiles"
  add_foreign_key "publisher_preferences", "organisations"
  add_foreign_key "publisher_preferences", "publishers"
  add_foreign_key "qualification_results", "qualifications"
  add_foreign_key "qualifications", "job_applications"
  add_foreign_key "qualifications", "jobseeker_profiles"
  add_foreign_key "reference_requests", "references"
  add_foreign_key "references", "job_applications"
  add_foreign_key "religious_reference_requests", "job_applications"
  add_foreign_key "saved_jobs", "jobseekers"
  add_foreign_key "saved_jobs", "vacancies"
  add_foreign_key "school_group_memberships", "organisations", column: "school_group_id"
  add_foreign_key "school_group_memberships", "organisations", column: "school_id"
  add_foreign_key "self_disclosure_requests", "job_applications"
  add_foreign_key "self_disclosures", "self_disclosure_requests"
  add_foreign_key "training_and_cpds", "job_applications"
  add_foreign_key "training_and_cpds", "jobseeker_profiles"
  add_foreign_key "vacancies", "organisations", column: "publisher_organisation_id"
  add_foreign_key "vacancies", "publisher_ats_api_clients"
  add_foreign_key "vacancies", "publishers"
  add_foreign_key "vacancy_analytics", "vacancies"
end
