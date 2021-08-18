class Vacancy < ApplicationRecord
  extend FriendlyId
  extend ArrayEnum

  include Indexable

  friendly_id :slug_candidates, use: %w[slugged history]

  # 'sen_specialist' role is being retired but still exists on vacancies.
  array_enum job_roles: { teacher: 0, leadership: 1, sen_specialist: 2, nqt_suitable: 3, education_support: 4, sendco: 5, send_responsible: 6 }
  array_enum working_patterns: { full_time: 0, part_time: 100, job_share: 101 }
  # Legacy vacancies can have these working_pattern options too: { compressed_hours: 102, staggered_hours: 103 }
  enum contract_type: { permanent: 0, fixed_term: 1 }
  enum status: { published: 0, draft: 1, trashed: 2 }
  enum job_location: { at_one_school: 0, at_multiple_schools: 1, central_office: 2 }
  enum end_listing_reason: { suitable_candidate_found: 0, end_early: 1 }
  enum candidate_hired_from: { teaching_vacancies: 0, other_free: 1, other_paid: 2, unknown: 3 }
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

  belongs_to :publisher, optional: true
  belongs_to :publisher_organisation, class_name: "Organisation", optional: true

  has_many_attached :supporting_documents

  has_many :saved_jobs, dependent: :destroy
  has_many :saved_by, through: :saved_jobs, source: :jobseeker

  has_many :job_applications, dependent: :destroy
  has_one :equal_opportunities_report, dependent: :destroy
  has_noticed_notifications

  has_many :organisation_vacancies, dependent: :destroy
  has_many :organisations, through: :organisation_vacancies, dependent: :destroy
  accepts_nested_attributes_for :organisation_vacancies

  delegate :name, to: :parent_organisation, prefix: true, allow_nil: true

  scope :active, (-> { where(status: %i[published draft]) })
  scope :applicable, (-> { where("expires_at >= ?", Time.current) })
  scope :awaiting_feedback, (-> { expired.where(listed_elsewhere: nil, hired_status: nil) })
  scope :expired, (-> { published.where("expires_at < ?", Time.current) })
  scope :expired_yesterday, (-> { where("expires_at BETWEEN ? AND ?", Time.zone.yesterday.midnight, Date.current.midnight) })
  scope :expires_within_data_access_period, (-> { where("expires_at >= ?", Time.current - DATA_ACCESS_PERIOD_FOR_PUBLISHERS) })
  scope :in_organisation_ids, (->(ids) { joins(:organisation_vacancies).where(organisation_vacancies: { organisation_id: ids }).distinct })
  scope :listed, (-> { published.where("publish_on <= ?", Date.current) })
  scope :live, (-> { listed.applicable })
  scope :pending, (-> { published.where("publish_on > ?", Date.current) })
  scope :published_on_count, (->(date) { published.where(publish_on: date.all_day).count })

  paginates_per 10

  validates :slug, presence: true
  validate :enable_job_applications_cannot_be_changed_once_listed

  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at

  EQUAL_OPPORTUNITIES_PUBLICATION_THRESHOLD = 5
  EXPIRY_TIME_OPTIONS = %w[7:00 8:00 9:00 10:00 11:00 12:00 13:00 14:00 15:00 16:00 17:00 23:59].freeze

  def organisation
    organisation_vacancies.first&.organisation
  end

  def parent_organisation
    organisations.many? ? organisations.first.school_groups.first : organisation
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

  def can_receive_job_applications?
    enable_job_applications? && published? && !pending?
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

  def education_phases
    organisations.map(&:readable_phases).flatten.uniq
  end

  def publish_equal_opportunities_report?
    job_applications.after_submission.count >= EQUAL_OPPORTUNITIES_PUBLICATION_THRESHOLD
  end

  def suitable_for_nqt
    # For both (1) editing/reviewing a vacancy and (2) validating all steps when publishing a vacancy,
    # we have to reconstruct the user's response to this question, because we don't store their
    # boolean answer in its own separate column, but rather in the job_roles array column.
    # But when we are showing the step for the first time, we should not pre-fill the NQT question with
    # 'no', so we should return 'nil' here.
    if job_roles.include?("nqt_suitable")
      "yes"
    elsif completed_steps.include?("job_details")
      "no"
    end
  end

  # rubocop:disable Naming/PredicateName
  def has_send_responsibilities
    # For both (1) editing/reviewing a vacancy and (2) validating all steps when publishing a vacancy,
    # we have to reconstruct the user's response to this question, because we don't store their
    # boolean answer in its own separate column, but rather in the job_roles array column.
    # But when we are showing the step for the first time, we should not pre-fill the SEND
    # responsibilities question with 'no', so we should return 'nil' here.
    if job_roles.include?("send_responsible")
      "yes"
    elsif completed_steps.include?("job_roles_more")
      "no"
    end
  end
  # rubocop:enable Naming/PredicateName

  def sendco?
    job_roles.include?("sendco")
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

  def enable_job_applications_cannot_be_changed_once_listed
    return unless persisted? && listed? && enable_job_applications_changed?

    errors.add(:enable_job_applications, :cannot_be_changed_once_listed)
  end
end
