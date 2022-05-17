require "geocoding"

class Vacancy < ApplicationRecord # rubocop:disable Metrics/ClassLength
  extend FriendlyId
  extend ArrayEnum

  include DatabaseIndexable
  include Resettable
  include Phaseable

  friendly_id :slug_candidates, use: %w[slugged history]

  # Each vacancy must have *exactly* one main job role. It may have zero or multiple additional job roles. Legacy
  # vacancies *may* have more than one main job role as we used to allow multiple.
  # TODO: This is a compromise to keep changes to the data model minimal for now. Once the legacy vacancies are gone,
  #       we should refactor the data model.
  MAIN_JOB_ROLES = { teacher: 0, senior_leader: 1, middle_leader: 7, teaching_assistant: 6, education_support: 4, sendco: 5 }.freeze
  ADDITIONAL_JOB_ROLES = { send_responsible: 2, ect_suitable: 3 }.freeze

  ATTRIBUTES_TO_TRACK_IN_ACTIVITY_LOG = %i[
    about_school application_link contact_email contact_number contract_type expires_at how_to_apply job_advert
    job_roles job_role_details job_title key_stages personal_statement_guidance salary school_visits subjects starts_on
    working_patterns
  ].freeze

  # When removing a job_role or working_pattern, remember to update *subscriptions* that have the old values.
  array_enum job_roles: MAIN_JOB_ROLES.merge(ADDITIONAL_JOB_ROLES)
  array_enum key_stages: { early_years: 0, ks1: 1, ks2: 2 }
  array_enum working_patterns: { full_time: 0, part_time: 100, flexible: 104, job_share: 101, term_time: 102 }
  # Legacy vacancies can have these working_pattern options too: { compressed_hours: 102, staggered_hours: 103 }

  enum contract_type: { permanent: 0, fixed_term: 1, parental_leave_cover: 2 }
  enum hired_status: { hired_tvs: 0, hired_other_free: 1, hired_paid: 2, hired_no_listing: 3, not_filled_ongoing: 4, not_filled_not_looking: 5, hired_dont_know: 6 }
  enum job_location: { at_one_school: 0, at_multiple_schools: 1, central_office: 2 }
  enum listed_elsewhere: { listed_paid: 0, listed_free: 1, listed_mix: 2, not_listed: 3, listed_dont_know: 4 }
  enum phase: { primary: 0, secondary: 1, "16-19": 2, multiple_phases: 3 }
  enum status: { published: 0, draft: 1, trashed: 2, removed_from_external_system: 3 }

  belongs_to :publisher, optional: true
  belongs_to :publisher_organisation, class_name: "Organisation", optional: true

  has_many_attached :supporting_documents
  has_one_attached :application_form

  has_many :saved_jobs, dependent: :destroy
  has_many :saved_by, through: :saved_jobs, source: :jobseeker
  has_many :job_applications, dependent: :destroy
  has_one :equal_opportunities_report, dependent: :destroy
  has_many :organisation_vacancies, dependent: :destroy
  has_many :organisations, through: :organisation_vacancies, dependent: :destroy, after_add: :refresh_geolocation, after_remove: :refresh_geolocation
  has_many :markers, dependent: :destroy

  delegate :name, to: :organisation, prefix: true, allow_nil: true

  scope :active, (-> { where(status: %i[published draft]) })
  scope :applicable, (-> { where("expires_at >= ?", Time.current) })
  scope :awaiting_feedback, (-> { expired.where(listed_elsewhere: nil, hired_status: nil) })
  scope :expired, (-> { published.where("expires_at < ?", Time.current) })
  scope :expired_yesterday, (-> { where("DATE(expires_at) = ?", 1.day.ago.to_date) })
  scope :expires_within_data_access_period, (-> { where("expires_at >= ?", Time.current - DATA_ACCESS_PERIOD_FOR_PUBLISHERS) })
  scope :in_organisation_ids, (->(ids) { joins(:organisation_vacancies).where(organisation_vacancies: { organisation_id: ids }).distinct })
  scope :listed, (-> { published.where("publish_on <= ?", Date.current) })
  scope :live, (-> { listed.applicable })
  scope :pending, (-> { published.where("publish_on > ?", Date.current) })
  scope :published_on_count, (->(date) { published.where(publish_on: date.all_day).count })

  scope :internal, (-> { where(external_source: nil) })
  scope :external, (-> { where.not(external_source: nil) })

  scope :search_within_area, ->(area) { where("ST_Intersects(?, geolocation)", area.to_s) }
  scope :search_by_filter, VacancyFilterQuery
  scope :search_by_location, VacancyLocationQuery
  scope :search_by_full_text, VacancyFullTextSearchQuery

  paginates_per 10

  validates :slug, presence: true
  validate :enable_job_applications_cannot_be_changed_once_listed
  validates_with ExternalVacancyValidator, if: :external?

  has_noticed_notifications
  has_paper_trail on: [:update],
                  only: ATTRIBUTES_TO_TRACK_IN_ACTIVITY_LOG,
                  if: proc { |vacancy| vacancy.listed? }

  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at
  before_save :refresh_geolocation, if: -> { job_location_changed? }
  after_save :reset_markers, if: -> { saved_change_to_status? && (listed? || pending?) }

  EQUAL_OPPORTUNITIES_PUBLICATION_THRESHOLD = 5
  EXPIRY_TIME_OPTIONS = %w[7:00 8:00 9:00 10:00 11:00 12:00 13:00 14:00 15:00 16:00 17:00 23:59].freeze

  # Class method added to help with the mapping of array_enums for paper_trail, which stores the changes
  # as an array of integers in the version.
  def self.array_enums
    {
      job_roles: job_roles,
      key_stages: key_stages,
      working_patterns: working_patterns,
    }
  end

  def self.main_job_role_options
    MAIN_JOB_ROLES.keys.map(&:to_s)
  end

  def self.additional_job_role_options
    ADDITIONAL_JOB_ROLES.keys.map(&:to_s)
  end

  def external?
    external_source.present?
  end

  def organisation
    @organisation ||= organisations.one? ? organisations.first : organisations.first&.school_groups&.first
  end

  def location
    [organisation&.name, organisation&.town, organisation&.county].reject(&:blank?)
  end

  def listed?
    published? && expires_at&.future? && (publish_on&.today? || publish_on&.past?)
  end

  def pending?
    published? && publish_on&.future?
  end

  def expired?
    published? && expires_at&.past?
  end

  def publication_status
    return "expired" if expired?
    return "pending" if pending?

    status
  end

  def can_receive_job_applications?
    enable_job_applications? && published? && !pending?
  end

  def allow_key_stages?
    !one_phase? || readable_phases == %w[primary] || readable_phases == %w[middle]
  end

  def allow_subjects?
    readable_phases != ["primary"]
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
    super(value)
  end

  def refresh_slug
    self.slug = nil
    send(:set_slug)
  end

  def attributes
    super().merge(
      "working_patterns" => working_patterns,
      "job_roles" => job_roles,
      "main_job_role" => main_job_role,
      "additional_job_roles" => additional_job_roles,
    )
  end

  def main_job_role
    # Legacy vacancies may have more than one main job role defined, but we still only care about the first
    job_roles.find { |role| role.in?(self.class.main_job_role_options) }
  end

  def main_job_role=(role)
    # Do nothing if main job role is unchanged. Else completely reset job_roles as additional roles may no longer be valid
    return if role == main_job_role

    self.job_roles = [role]
  end

  def additional_job_roles
    job_roles.select { |role| role.in?(self.class.additional_job_role_options) }
  end

  def additional_job_roles=(roles)
    self.job_roles = [main_job_role] + roles
  end

  def publish_equal_opportunities_report?
    job_applications.after_submission.count >= EQUAL_OPPORTUNITIES_PUBLICATION_THRESHOLD
  end

  def set_postcode_from_mean_geolocation(persist: true)
    # When SimilarJobs searches for jobs similar to a multi-school job, we need to derive a location to search around.
    # Take the mean of the geopoints of the school(s) the vacancy is at, and use it to look up a human-readable
    # version of that location (i.e. a postcode).
    return if central_office?

    if at_one_school?
      postcode = organisation.postcode
    else
      schools = organisations.schools.where.not(geopoint: nil)
      centroid = schools.pluck(Arel.sql("ST_Centroid(ST_Collect(geopoint::geometry))::geography")).first
      return unless centroid

      postcode = Geocoding.new([centroid.x, centroid.y]).postcode_from_coordinates
    end
    return unless postcode

    self.postcode_from_mean_geolocation = postcode
    save if persist
    postcode
  end

  def reset_markers
    markers.delete_all
    organisations.each do |organisation|
      markers.create(organisation: organisation, geopoint: organisation.geopoint)
    end
  end

  private

  def slug_candidates
    [:job_title, %i[job_title organisation_name], %i[job_title location]]
  end

  def on_expired_vacancy_feedback_submitted_update_stats_updated_at
    return unless listed_elsewhere_changed? && hired_status_changed?

    self.stats_updated_at = Time.current
  end

  def enable_job_applications_cannot_be_changed_once_listed
    return unless persisted? && listed? && enable_job_applications_changed?

    errors.add(:enable_job_applications, :cannot_be_changed_once_listed)
  end

  # This method is used as a callback when either:
  #   * an organisation association is added or removed, or
  #   * the job location was changed to "central office"
  # In the former case, it gets an argument, which we don't need and thus ignore
  def refresh_geolocation(_school_added_or_removed = nil)
    self.geolocation = if central_office? || at_one_school?
                         organisation&.geopoint
                       else
                         points = organisations.filter_map(&:geopoint)
                         points.presence && points.first.factory.multi_point(points)
                       end
    reset_markers if persisted? && (listed? || pending?)
  end
end
