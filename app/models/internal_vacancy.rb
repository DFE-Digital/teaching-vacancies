# frozen_string_literal: true

class InternalVacancy < Vacancy
  include ActionView::Helpers::SanitizeHelper

  scope :draft, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }
  scope :pending, -> { kept.where("publish_on > ?", Date.current) }

  scope :awaiting_feedback_recently_expired, -> { where(listed_elsewhere: nil, hired_status: nil).where(expires_at: 2.months.ago..) }

  validate :enable_job_applications_cannot_be_changed_once_listed, if: -> { persisted? && live? && enable_job_applications_changed? }
  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at, if: -> { listed_elsewhere_changed? && hired_status_changed? }

  validates :organisations, presence: true

  validates :job_title, presence: true
  validates :job_title, length: { minimum: 4, maximum: 75 }, if: -> { job_title.present? }
  validate :job_title_has_no_tags?, if: proc { job_title.present? }

  validates :job_roles, presence: true
  validate :job_roles_inclusion, if: -> { job_roles.present? }

  validates :phases, presence: true, inclusion: { in: phases.keys }

  validate :key_stages_in_phase

  validates :job_address_line1, presence: true, if: :any_address_field_present?
  validates :job_address_town, presence: true, if: :any_address_field_present?
  validates :job_address_postcode, presence: true, if: :any_address_field_present?

  WORKING_PATTERNS_DETAILS_MAX_WORDS = 75

  validates :contract_type, inclusion: { in: Vacancy.contract_types.keys }
  validates :working_patterns, presence: true, inclusion: { in: WORKING_PATTERNS }
  validates :fixed_term_contract_duration, presence: true, if: -> { contract_type == "fixed_term" }
  validates :is_parental_leave_cover, inclusion: { in: [true, false] }, if: -> { contract_type == "fixed_term" }
  validates :is_job_share, inclusion: { in: [true, false] }
  validate :working_patterns_details_does_not_exceed_maximum_words

  SALARIES = {
    salary: "full_time",
    actual_salary: "part_time",
    pay_scale: "pay_scale",
    hourly_rate: "hourly_rate",
  }.freeze

  validate :salary_presence
  SALARIES.each_key do |key|
    validates key, length: { minimum: 1, maximum: 256 }, if: -> { public_send(key).present? }
  end
  validates :benefits, inclusion: { in: [true, false] }
  validates :benefits_details, presence: true, length: { minimum: 1, maximum: 256 }, if: -> { benefits }

  def salary_types
    SALARIES.keys.map { |s| public_send(s) }.compact_blank
  end

  validates :start_date_type, inclusion: { in: start_date_types.keys }
  validates :starts_on, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :expires_at }, if: -> { start_date_type == "specific_date" }
  validates :earliest_start_date, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :expires_at }, if: -> { start_date_type == "date_range" }
  validates :latest_start_date, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :earliest_start_date }, if: -> { start_date_type == "date_range" }
  validates :other_start_date_details, presence: true, if: -> { start_date_type == "other" }

  private

  def on_expired_vacancy_feedback_submitted_update_stats_updated_at
    self.stats_updated_at = Time.current
  end

  def enable_job_applications_cannot_be_changed_once_listed
    errors.add(:enable_job_applications, :cannot_be_changed_once_listed)
  end

  def job_title_has_no_tags?
    job_title_without_escaped_characters = job_title.delete("&")
    return false if job_title_without_escaped_characters == sanitize(job_title_without_escaped_characters, tags: [])

    errors.add(:job_title, I18n.t("job_title_errors.job_title.invalid_characters"))
  end

  def job_roles_inclusion
    job_roles.each do |role|
      errors.add(:job_roles, "Invalid job role") unless Vacancy.job_roles.key?(role)
    end
  end

  def key_stages_in_phase
    return if key_stages&.any? && key_stages&.all? { |ks| key_stages_for_phases.include? ks.to_sym }

    errors.add(:key_stages, :inclusion)
  end

  def any_address_field_present?
    [job_address_line1, job_address_line2, job_address_town, job_address_county, job_address_postcode].any?(&:present?)
  end

  def working_patterns_details_does_not_exceed_maximum_words
    return unless number_of_words_exceeds_permitted_length?(WORKING_PATTERNS_DETAILS_MAX_WORDS, working_patterns_details)

    errors.add(:working_patterns_details,
               :working_patterns_details_maximum_words,
               message: I18n.t("contract_information_errors.working_patterns_details.maximum_words"))
  end

  def number_of_words_exceeds_permitted_length?(number, attribute)
    number_of_words = remove_html_tags(attribute)&.split&.length

    number_of_words&.>(number)
  end

  def remove_html_tags(field)
    regex = /<("[^"]*"|'[^']*'|[^'">])*>/

    field&.gsub(regex, "")
  end

  def salary_presence
    errors.add(:salary_types) if salary_types.blank? || salary_types.none?
  end
end
