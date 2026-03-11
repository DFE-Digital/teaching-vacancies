class CreateVacancyTemplates < ActiveRecord::Migration[8.0]
  def change
    # create_table :vacancy_templates, id: :uuid, &:timestamps
    # create_table :vacancy_templates, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
    create_table :vacancy_templates, id: :uuid do |t|
      t.string :name
      t.timestamps
      t.text "benefits_details"
      # t.date "starts_on"
      t.string "contact_email"
      # t.date "publish_on"
      t.integer "working_patterns", array: true
      # t.integer "hired_status"
      # t.datetime "stats_updated_at", precision: nil
      # t.uuid "publisher_id"
      # t.datetime "expires_at", precision: nil
      t.string "salary"
      # t.text "about_school"
      t.string "subjects", array: true
      # t.integer "job_location"
      # t.string "readable_job_location"
      t.integer "job_roles", array: true
      t.string "contact_number"
      # t.uuid "publisher_organisation_id"
      # t.boolean "starts_asap"
      t.integer "contract_type"
      t.string "fixed_term_contract_duration"
      t.boolean "enable_job_applications"
      # t.string "completed_steps", default: [], null: false, array: true
      t.string "actual_salary"
      t.text "working_patterns_details"
      t.integer "key_stages", array: true
      # t.string "readable_phases", default: [], array: true
      # t.tsvector "searchable_content"
      # t.boolean "google_index_removed", default: false
      t.string "parental_leave_cover_contract_duration"
      # t.datetime "expired_vacancy_feedback_email_sent_at", precision: nil
      # t.string "external_source"
      # t.string "external_reference"
      # t.string "external_advert_url"
      t.integer "ect_status"
      t.string "pay_scale"
      t.boolean "benefits"
      t.text "full_time_details"
      t.text "part_time_details"
      t.integer "phases", array: true
      # t.integer "start_date_type"
      # t.date "earliest_start_date"
      # t.date "latest_start_date"
      # t.text "other_start_date_details"
      t.integer "receive_applications"
      t.string "application_email"
      t.boolean "school_visits"
      # t.boolean "contact_number_provided"
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
      # t.integer "extension_reason"
      # t.string "other_extension_reason_details"
      # t.uuid "publisher_ats_api_client_id"
      t.integer "religion_type"
      t.boolean "flexi_working_details_provided"
      # t.datetime "discarded_at"
      # t.string "type", null: false
      t.boolean "anonymise_applications", default: false
      # t.index ["contact_email"], name: "index_vacancies_on_contact_email"
      # t.index ["publisher_id"], name: "index_vacancies_on_publisher_id"
      # t.index ["publisher_organisation_id"], name: "index_vacancies_on_publisher_organisation_id"
    end
  end
end
