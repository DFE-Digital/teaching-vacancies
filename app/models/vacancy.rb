require "auditor"

class Vacancy < ApplicationRecord
  extend FriendlyId
  extend ArrayEnum

  include ApplicationHelper
  include Auditor::Model
  include DatesHelper
  include Indexable
  include Redis::Objects
  include VacancyJobSpecificationValidations
  include VacancyPayPackageValidations
  include VacancyImportantDateValidations
  include VacancyApplicationDetailValidations
  include VacancyJobSummaryValidations

  JOB_ROLE_OPTIONS = {
    teacher: 0,
    leadership: 1,
    sen_specialist: 2,
    nqt_suitable: 3,
  }.freeze

  WORKING_PATTERN_OPTIONS = {
    full_time: 0,
    part_time: 100,
    job_share: 101,
    # Legacy vacancies can have these options too
    # compressed_hours: 102,
    # staggered_hours: 103
  }.freeze

  JOB_SORTING_OPTIONS = [
    [I18n.t("jobs.sort_by.most_relevant"), ""],
    [I18n.t("jobs.sort_by.publish_on.descending"), "publish_on_desc"],
    [I18n.t("jobs.sort_by.expiry_time.descending"), "expiry_time_desc"],
    [I18n.t("jobs.sort_by.expiry_time.ascending"), "expiry_time_asc"],
  ].freeze

  JOB_LOCATION_OPTIONS = {
    at_one_school: 0,
    at_multiple_schools: 1,
    central_office: 2,
  }.freeze

  friendly_id :slug_candidates, use: %w[slugged history]

  enum status: { published: 0, draft: 1, trashed: 2 }
  enum job_location: { at_one_school: 0, at_multiple_schools: 1, central_office: 2 }
  array_enum job_roles: JOB_ROLE_OPTIONS
  array_enum working_patterns: WORKING_PATTERN_OPTIONS
  enum listed_elsewhere: {
    listed_paid: 0,
    listed_free: 1,
    listed_mix: 2,
    not_listed: 3,
    listed_dont_know: 4,
  }
  enum hired_status: {
    hired_tvs: 0,
    hired_other_free: 1,
    hired_paid: 2,
    hired_no_listing: 3,
    not_filled_ongoing: 4,
    not_filled_not_looking: 5,
    hired_dont_know: 6,
  }

  belongs_to :publisher_user, class_name: "User", optional: true
  belongs_to :publisher_organisation, class_name: "Organisation", optional: true

  has_one :publish_feedback, class_name: "VacancyPublishFeedback"

  has_many :documents

  has_many :organisation_vacancies, dependent: :destroy
  has_many :organisations, through: :organisation_vacancies
  accepts_nested_attributes_for :organisation_vacancies

  delegate :name, to: :parent_organisation, prefix: true, allow_nil: true

  acts_as_gov_uk_date :starts_on, :publish_on,
                      :expires_on, error_clash_behaviour: :omit_gov_uk_date_field_error

  scope :active, (-> { where(status: %i[published draft]) })
  scope :applicable, (-> { where("expiry_time >= ?", Time.current) })
  scope :expired, (-> { where("expiry_time < ?", Time.current) })
  scope :awaiting_feedback, (-> { expired.where(listed_elsewhere: nil, hired_status: nil) })
  scope :listed, (-> { published.where("publish_on <= ?", Date.current) })
  scope :pending, (-> { published.where("publish_on > ?", Date.current) })
  scope :live, (-> { listed.applicable })
  scope :published_on_count, (->(date) { published.where(publish_on: date.all_day).count })
  scope :in_organisation_ids, (->(ids) { joins(:organisation_vacancies).where(organisation_vacancies: { organisation_id: ids }).distinct })

  paginates_per 10

  validates :slug, presence: true

  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at

  counter :page_view_counter
  counter :get_more_info_counter

  def organisation
    organisation_vacancies.first&.organisation
  end

  def parent_organisation
    organisations.many? ? organisations.first.school_groups.first : organisation
  end

  def location
    [organisation&.name, organisation&.town, organisation&.county].reject(&:blank?)
  end

  def coordinates
    return if organisation&.geolocation.nil?

    {
      lat: organisation.geolocation.x.to_f,
      lon: organisation.geolocation.y.to_f,
    }
  end

  def listed?
    published? && expiry_time&.future? && (publish_on&.today? || publish_on&.past?)
  end

  def trash!
    self.status = :trashed
    save(validate: false)
  end

  def application_link=(value)
    # Data may not include a scheme/protocol so we must be careful when creating
    # links that Rails doesn't make them incorrectly relative.
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
    super().merge("working_patterns" => working_patterns, "job_roles" => job_roles)
  end

  def skip_update_callbacks(value = true)
    @skip_update_callbacks = value
  end

  def skip_update_callbacks?
    @skip_update_callbacks.present?
  end

  def any_candidate_specification?
    experience.present? || qualifications.present? || education.present?
  end

  def delete_documents
    documents.each { |document| DocumentDelete.new(document).delete }
  end

  def education_phases
    organisations.map(&:readable_phases).flatten.uniq
  end

private

  def slug_candidates
    [
      :job_title,
      %i[job_title parent_organisation_name],
      %i[job_title location],
    ]
  end

  def on_expired_vacancy_feedback_submitted_update_stats_updated_at
    return unless listed_elsewhere_changed? && hired_status_changed?

    self.stats_updated_at = Time.current
  end
end
