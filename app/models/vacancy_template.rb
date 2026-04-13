# frozen_string_literal: true

class VacancyTemplate < ApplicationRecord
  include Resettable

  IGNORED_ATTRIBUTES = %w[
    id
    job_title
    slug
    job_advert
    starts_on
    publish_on
    application_link
    listed_elsewhere
    hired_status
    stats_updated_at
    publisher_id
    expires_at
    about_school
    job_location
    readable_job_location
    publisher_organisation_id
    starts_asap
    completed_steps
    geolocation
    readable_phases
    searchable_content
    google_index_removed
    expired_vacancy_feedback_email_sent_at
    external_source
    external_reference
    external_advert_url
    start_date_type
    earliest_start_date
    latest_start_date
    other_start_date_details
    contact_number_provided
    extension_reason
    other_extension_reason_details
    publisher_ats_api_client_id
    discarded_at
    type
    uk_geolocation
    contact_email
    application_email
    contact_number
    parental_leave_cover_contract_duration
    include_additional_documents
  ].freeze

  extend ArrayEnum
  include VacancyChecks

  belongs_to :organisation

  validates :name, presence: true

  array_enum job_roles: Vacancy::JOB_ROLES
  enum :ect_status, Vacancy::ECT_STATUSES
  enum :contract_type, Vacancy::CONTRACT_TYPES
  array_enum key_stages: Vacancy::KEY_STAGES
  array_enum phases: Vacancy::PHASES
  array_enum working_patterns: Vacancy::WORKING_PATTERNS_ENUM

  # These are set when enable_job_applications is false.
  # 0 was for email applications (on vacancy, but removed 24/7/25)
  enum :receive_applications, { website: 1, uploaded_form: 2 }

  enum :religion_type, Vacancy::RELIGION_TYPES

  def central_office?
    false
  end

  def for_multiple_organisations?
    false
  end

  def resettable?
    true
  end

  def reset_application_form; end
  def reset_documents; end
  def reset_contact_number; end
  def reset_application_email; end

  def vacancy_attributes
    attributes.symbolize_keys.except(:id, :name, :job_roles, :organisation_id,
                                     :phases, :key_stages, :working_patterns)
                                          .merge(job_roles: job_roles,
                                                 working_patterns: working_patterns,
                                                 key_stages: key_stages,
                                                 phases: phases)
  end
end
