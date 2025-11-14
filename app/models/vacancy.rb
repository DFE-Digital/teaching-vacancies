require "geocoding"

# rubocop:disable Metrics/ClassLength
class Vacancy < ApplicationRecord
  extend FriendlyId
  extend ArrayEnum

  include DatabaseIndexable
  include Resettable

  include Discard::Model

  friendly_id :slug_candidates, use: %w[slugged history]

  # TODO: Update with job listing updates
  ATTRIBUTES_TO_TRACK_IN_ACTIVITY_LOG = %i[
    application_link contact_email contact_number contract_type expires_at
    job_roles job_title key_stages personal_statement_guidance salary school_visits subjects starts_on
    working_patterns
  ].freeze

  PHASES_TO_KEY_STAGES_MAPPINGS = {
    nursery: %i[early_years],
    primary: %i[early_years ks1 ks2],
    secondary: %i[ks3 ks4 ks5],
    sixth_form_or_college: %i[ks5],
    through: %i[early_years ks1 ks2 ks3 ks4 ks5],
  }.freeze

  JOB_ROLES = { "teacher" => 0, "headteacher" => 1, "deputy_headteacher" => 2, "assistant_headteacher" => 3,
                "head_of_year_or_phase" => 4, "head_of_department_or_curriculum" => 5, "teaching_assistant" => 6,
                "higher_level_teaching_assistant" => 7, "education_support" => 8, "sendco" => 9, "administration_hr_data_and_finance" => 11,
                "catering_cleaning_and_site_management" => 12, "it_support" => 13, "pastoral_health_and_welfare" => 14,
                "other_leadership" => 15, "other_support" => 16 }.freeze

  MIDDLE_LEADER_JOB_ROLES = %w[head_of_year_or_phase head_of_department_or_curriculum].freeze
  SENIOR_LEADER_JOB_ROLES = %w[headteacher deputy_headteacher assistant_headteacher].freeze

  TEACHING_JOB_ROLES = %w[teacher head_of_year_or_phase head_of_department_or_curriculum assistant_headteacher
                          deputy_headteacher headteacher sendco other_leadership].freeze
  SUPPORT_JOB_ROLES = %w[teaching_assistant higher_level_teaching_assistant education_support
                         administration_hr_data_and_finance catering_cleaning_and_site_management
                         it_support pastoral_health_and_welfare other_support].freeze

  SCHOOL_PHASES_MATCHING_VACANCY_PHASES = %w[nursery primary secondary sixth_form_or_college].freeze

  # 'job_share' now gets stored in "is_job_share".
  # PR: https://github.com/DFE-Digital/teaching-vacancies/pull/6966
  # TODO: - Check if the rake task migrating it was run and no "job_share" values are left on "working_patterns".
  #       - Check that no code depends on the keys containing "job_share".
  #       - Remove the key from the array_enum if the above conditions are met.
  LEGACY_WORKING_PATTERNS = %w[job_share].freeze
  WORKING_PATTERNS = %w[full_time part_time].freeze

  array_enum key_stages: { early_years: 0, ks1: 1, ks2: 2, ks3: 3, ks4: 4, ks5: 5 }
  array_enum working_patterns: { full_time: 0, part_time: 100, job_share: 101 }
  # middle(2) removed and converted to primary/secondary to avoid missing middle school roles in primary/secondary filters
  array_enum phases: { nursery: 0, primary: 1, secondary: 3, sixth_form_or_college: 4, through: 5 }
  array_enum job_roles: JOB_ROLES
  # removed parental_leave_cover: 2 from contract types. No instances in DB.
  enum :contract_type, { permanent: 0, fixed_term: 1, casual: 3 }
  enum :ect_status, { ect_suitable: 0, ect_unsuitable: 1 }
  enum :hired_status, { hired_tvs: 0, hired_other_free: 1, hired_paid: 2, hired_no_listing: 3, not_filled_ongoing: 4, not_filled_not_looking: 5, hired_dont_know: 6 }
  enum :listed_elsewhere, { listed_paid: 0, listed_free: 1, listed_mix: 2, not_listed: 3, listed_dont_know: 4 }
  enum :start_date_type, { specific_date: 0, date_range: 1, other: 2, undefined: 3, asap: 4 }

  # These are set when enable_job_applications is false. email is a legacy value no longer settable from front-end 24/7/2025
  # cannot be validated as this is asked as a separate question from enable_job_applications
  enum :receive_applications, { email: 0, website: 1, uploaded_form: 2 }

  enum :extension_reason, { no_applications: 0, didnt_find_right_candidate: 1, other_extension_reason: 2 }
  enum :religion_type, { no_religion: 0, other_religion: 1, catholic: 2 }

  belongs_to :publisher, optional: true
  belongs_to :publisher_organisation, class_name: "Organisation", optional: true
  belongs_to :publisher_ats_api_client, optional: true

  DOCUMENT_FILE_SIZE_LIMIT = 20.megabytes
  DOCUMENT_CONTENT_TYPES = %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document].freeze

  DOCUMENT_VALIDATION_OPTIONS = {
    file_type: :document,
    content_types_allowed: DOCUMENT_CONTENT_TYPES,
    file_size_limit: DOCUMENT_FILE_SIZE_LIMIT,
    valid_file_types: %i[PDF DOC DOCX],
  }.freeze

  has_many_attached :supporting_documents, service: :amazon_s3_documents

  validates :supporting_documents, content_type: DOCUMENT_CONTENT_TYPES,
                                   size: { less_than: DOCUMENT_FILE_SIZE_LIMIT }, virus_free: true, if: -> { include_additional_documents }

  has_one_attached :application_form, service: :amazon_s3_documents

  has_many :saved_jobs, dependent: :destroy
  has_many :saved_by, through: :saved_jobs, source: :jobseeker
  has_many :job_applications, dependent: :destroy
  has_one :equal_opportunities_report, dependent: :destroy
  has_many :organisation_vacancies, dependent: :destroy
  has_many :organisations,
           through: :organisation_vacancies,
           dependent: :destroy,
           validate: false, # If an organisation has some validation error, we do not want to block users from creating a vacancy.
           after_add: :refresh_geolocation,
           after_remove: :refresh_geolocation
  has_many :markers, dependent: :destroy
  has_many :feedbacks, dependent: :destroy, inverse_of: :vacancy
  has_one :vacancy_analytics, dependent: :destroy
  has_many :job_application_batches, dependent: :destroy

  delegate :name, to: :organisation, prefix: true, allow_nil: true

  scope :in_organisation_ids, ->(ids) { joins(:organisation_vacancies).where(organisation_vacancies: { organisation_id: ids }).distinct }
  scope :quick_apply, -> { where(enable_job_applications: true) }
  scope :visa_sponsorship_available, -> { where(visa_sponsorship_available: true) }

  scope :internal, -> { where(external_source: nil, publisher_ats_api_client_id: nil) }
  # Not called from the code but frequently used for filtering during manual debugging sessions
  scope :external, -> { where.not(external_source: nil).or(where.not(publisher_ats_api_client_id: nil)) }

  # we need these 3 tiny modules to provide 'scoping glue' between the model and the queries
  # so that if we can use PublishedVacancy and DraftVacancy safely
  extend VacancyFilterQueryModule

  scope :search_by_filter, ->(filters) { vacancy_filter_query(filters) }
  extend VacancyLocationQueryModule

  scope :search_by_location, ->(location_query, radius_in_miles, polygon:, sort_by_distance:) { vacancy_location_query(location_query, radius_in_miles, polygon: polygon, sort_by_distance: sort_by_distance) }
  extend VacancyFulTextSearchQueryModule

  scope :search_by_full_text, ->(query) { vacancy_full_text_search_query(query) }

  scope :active_in_current_academic_year, lambda {
    sept_1st = Date.current.beginning_of_year.months_since(8)
    academic_year_start = if Date.current < sept_1st
                            sept_1st - 1.year
                          else
                            sept_1st
                          end
    published_in_year = where(publish_on: academic_year_start..Date.current)
    expired_in_year = where(publish_on: ..Date.current, expires_at: academic_year_start..)
    published_in_year.or(expired_in_year)
  }

  validates :slug, presence: true
  validates :organisations, presence: true

  validates :application_email, email_address: true, if: -> { application_email_changed? } # Allows data created prior to validation to still be valid
  validates :contact_email, email_address: true, if: -> { contact_email_changed? }

  has_noticed_notifications
  has_paper_trail on: [:update],
                  only: ATTRIBUTES_TO_TRACK_IN_ACTIVITY_LOG,
                  if: proc(&:live?)

  # Publisher will need to set a new publish date if wanting to re-publish an scheduled vacancy turned back to a draft.
  before_save -> { self.publish_on = nil if type_changed?(from: "PublishedVacancy", to: "DraftVacancy") }

  after_save :reset_markers, if: -> { saved_change_to_type? && (live? || pending?) }
  after_save :update_conversation_searchable_content, if: -> { saved_change_to_job_title? }

  EQUAL_OPPORTUNITIES_PUBLICATION_THRESHOLD = 5
  EXPIRY_TIME_OPTIONS = %w[8:00 9:00 12:00 15:00 23:59].freeze

  # Class method added to help with the mapping of array_enums for paper_trail, which stores the changes
  # as an array of integers in the version.
  def self.array_enums
    {
      job_roles: job_roles,
      key_stages: key_stages,
      working_patterns: working_patterns,
    }
  end

  def external?
    external_source.present? || publisher_ats_api_client.present?
  end

  def organisation
    return organisations.first if organisations.one?

    organisations.find(&:trust?) || publisher_organisation || organisations.first&.school_groups&.first
  end

  def trust_uid
    org = organisation # So the queries for retrieving the organisation only run once.
    if org.is_a?(SchoolGroup)
      org.uid
    else
      org.school_groups.trusts.first&.uid
    end
  end

  def location
    [organisation&.name, organisation&.town, organisation&.county].reject(&:blank?)
  end

  def central_office?
    organisations.one? && organisations.first.trust?
  end

  def live?
    published? && expires_at&.future? && (publish_on&.today? || publish_on&.past?)
  end

  def pending?
    published? && publish_on&.future?
  end

  def can_receive_job_applications?
    enable_job_applications? && published? && !pending?
  end

  def allow_key_stages?
    allowed_phases = %w[primary secondary through]
    allowed_roles = %w[teacher headteacher deputy_headteacher assistant_headteacher
                       head_of_year_or_phase head_of_department_or_curriculum teaching_assistant]

    phases.intersect?(allowed_phases) && job_roles.intersect?(allowed_roles)
  end

  def allow_phase_to_be_set?
    school_phases = organisations.schools.filter_map(&:phase).uniq

    !(school_phases.intersect? SCHOOL_PHASES_MATCHING_VACANCY_PHASES)
  end

  def allow_subjects?
    phases.any? { |phase| phase.in? %w[secondary sixth_form_or_college through] }
  end

  def key_stages_for_phases
    phases.map { |phase| PHASES_TO_KEY_STAGES_MAPPINGS[phase.to_sym] }.flatten.uniq.sort
  end

  def within_data_access_period?
    expires_at > DATA_ACCESS_PERIOD_FOR_PUBLISHERS.ago
  end

  def application_link=(value)
    # Data may not include a scheme/protocol so we must be careful when creating links that Rails doesn't make them incorrectly relative.
    begin
      value = Addressable::URI.heuristic_parse(value).to_s
    rescue Addressable::URI::InvalidURIError
      Rails.logger.debug("Validation error: Invalid application link format")
    end
    super
  end

  def refresh_slug
    self.slug = nil
    send(:set_slug)
  end

  def attributes
    super.merge("working_patterns" => working_patterns)
  end

  def publish_equal_opportunities_report?
    job_applications.after_submission.count >= EQUAL_OPPORTUNITIES_PUBLICATION_THRESHOLD
  end

  def reset_markers
    markers.delete_all
    organisations.each do |organisation|
      markers.create(organisation: organisation, geopoint: organisation.geopoint)
    end
  end

  def salary_types
    [
      salary.present? ? "full_time" : nil,
      actual_salary.present? ? "part_time" : nil,
      pay_scale.present? ? "pay_scale" : nil,
      hourly_rate.present? ? "hourly_rate" : nil,
    ]
  end

  def distance_in_miles_to(search_coordinates)
    if geolocation.is_a? RGeo::Geographic::SphericalMultiPointImpl
      # if there are multiple geolocations then return the distance to the nearest one to the given search location
      geolocation.map { |geolocation| calculate_distance(search_coordinates, geolocation) }.min
    else
      calculate_distance(search_coordinates, geolocation)
    end
  end

  def teaching_or_middle_leader_role?
    job_roles.intersect?(TEACHING_JOB_ROLES)
  end

  def allow_job_applications?
    enable_job_applications? || uploaded_form?
  end

  def create_job_application_for(jobseeker)
    klass = uploaded_form? ? UploadedJobApplication : NativeJobApplication
    jobseeker.job_applications.create!(vacancy: self, type: klass.name)
  end

  def contact_email_belongs_to_a_publisher?
    return false unless contact_email

    Publisher.find_by(email: contact_email).present?
  end

  private

  def update_conversation_searchable_content
    Conversation.joins(job_application: :vacancy)
                .where(job_applications: { vacancy_id: id })
                .find_each(&:update_searchable_content)
  end

  def calculate_distance(search_coordinates, geolocation)
    Geocoder::Calculations.distance_between(search_coordinates, [geolocation.latitude, geolocation.longitude])
  end

  def slug_candidates
    [:job_title, %i[job_title organisation_name], %i[job_title location]]
  end

  # This method is used as a callback when either:
  #   * an organisation association is added or removed, or
  #   * the job location was changed to "central office"
  # In the former case, it gets an argument, which we don't need and thus ignore
  def refresh_geolocation(_school_added_or_removed = nil)
    self.geolocation = if organisations.one?
                         organisation&.geopoint
                       else
                         points = organisations.filter_map(&:geopoint)
                         points.presence && points.first.factory.multi_point(points)
                       end
    reset_markers if persisted? && (live? || pending?)
  end
end
# rubocop:enable Metrics/ClassLength
