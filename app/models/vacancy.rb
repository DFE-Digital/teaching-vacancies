require 'auditor'

class Vacancy < ApplicationRecord
  JOB_ROLE_OPTIONS = [
    I18n.t('jobs.job_role_options.teacher'),
    I18n.t('jobs.job_role_options.leadership'),
    I18n.t('jobs.job_role_options.sen_specialist'),
    I18n.t('jobs.job_role_options.nqt_suitable'),
  ].freeze

  FLEXIBLE_WORKING_PATTERN_OPTIONS = {
    'part_time' => 100,
    'job_share' => 101,
    'compressed_hours' => 102,
    'staggered_hours' => 103
  }.freeze

  WORKING_PATTERN_OPTIONS = {
    'full_time' => 0
  }.merge(FLEXIBLE_WORKING_PATTERN_OPTIONS).freeze

  JOB_SORTING_OPTIONS = [
    [I18n.t('jobs.sort_by.most_relevant'), ''],
    [I18n.t('jobs.sort_by.publish_on.descending'), 'publish_on_desc'],
    [I18n.t('jobs.sort_by.publish_on.ascending'), 'publish_on_asc'],
    [I18n.t('jobs.sort_by.expiry_time.descending'), 'expiry_time_desc'],
    [I18n.t('jobs.sort_by.expiry_time.ascending'), 'expiry_time_asc']
  ]

  include ApplicationHelper
  include Auditor::Model

  include VacancyJobSpecificationValidations
  include VacancyPayPackageValidations
  include VacancyApplicationDetailValidations
  include VacancyJobSummaryValidations

  include Redis::Objects

  include AlgoliaSearch
  AlgoliaSearch::IndexSettings::DEFAULT_BATCH_SIZE = 100

  # For guidance on sanity-checking an indexing change, read documentation/algolia_sanity_check.md

  # rubocop:disable Metrics/BlockLength
  # rubocop:disable Metrics/LineLength
  # There must be a better way to pass these settings to the block, but everything seems to break
  algoliasearch index_name: Rails.env.test? ? "Vacancy_test#{ENV.fetch('GITHUB_RUN_ID', '')}" : 'Vacancy', auto_index: Rails.env.production?, auto_remove: Rails.env.production?, synchronous: Rails.env.test?, disable_indexing: !(Rails.env.production? || Rails.env.test?) do
    attributes :job_roles, :job_title, :salary, :working_patterns, :subjects

    attribute :expires_at do
      expires_at.to_s
    end

    attribute :expires_at_timestamp do
      expires_at.to_i
    end

    JOB_ROLE_OPTIONS.size.times do |index|
      attribute "job_role_#{index}".to_sym do
        self.job_roles[index] if self.job_roles.present?
      end
    end

    attribute :job_summary do
      self.job_summary&.truncate(256)
    end

    attribute :last_updated_at do
      # Convert from ActiveSupport::TimeWithZone object to Unix time
      self.updated_at.to_i
    end

    attribute :listing_status do
      self.status
    end

    attribute :newly_qualified_teacher_status do
      self.newly_qualified_teacher
    end

    attribute :permalink do
      self.slug
    end

    attribute :publication_date do
      self.publish_on&.to_s
    end

    attribute :publication_date_timestamp do
      self.publish_on&.to_datetime&.to_i
    end

    attribute :school do
      school = self.school
      { name: school.name,
        county: school.county,
        detailed_school_type: school.detailed_school_type&.label,
        local_authority: school.local_authority,
        phase: school.phase,
        religious_character: school.gias_data['ReligiousCharacter (name)'],
        region: school.region&.name,
        school_type: school.school_type&.label&.singularize,
        town: school.town }
    end

    attribute :start_date do
      self.starts_on&.to_s
    end

    attribute :start_date_timestamp do
      self.starts_on&.to_datetime&.to_i
    end

    geoloc :lat, :lng

    attributesForFaceting [:job_roles, :working_patterns, :school, :listing_status]

    add_replica Rails.env.test? ? "Vacancy_test#{ENV.fetch('GITHUB_RUN_ID', '')}_publish_on_desc" : 'Vacancy_publish_on_desc', inherit: true do
      ranking ['desc(publication_date_timestamp)']
    end

    add_replica Rails.env.test? ? "Vacancy_test#{ENV.fetch('GITHUB_RUN_ID', '')}_publish_on_asc" : 'Vacancy_publish_on_asc', inherit: true do
      ranking ['asc(publication_date_timestamp)']
    end

    add_replica Rails.env.test? ? "Vacancy_test#{ENV.fetch('GITHUB_RUN_ID', '')}_expiry_time_desc" : 'Vacancy_expiry_time_desc', inherit: true do
      ranking ['desc(expires_at_timestamp)']
    end

    add_replica Rails.env.test? ? "Vacancy_test#{ENV.fetch('GITHUB_RUN_ID', '')}_expiry_time_asc" : 'Vacancy_expiry_time_asc', inherit: true do
      ranking ['asc(expires_at_timestamp)']
    end
  end
  # rubocop:enable Metrics/LineLength
  # rubocop:enable Metrics/BlockLength

  def lat
    self.school.geolocation&.x&.to_f
  end

  def lng
    self.school.geolocation&.y&.to_f
  end

  extend FriendlyId
  extend ArrayEnum

  friendly_id :slug_candidates, use: %w[slugged history]

  enum status: { published: 0, draft: 1, trashed: 2 }
  array_enum working_patterns: WORKING_PATTERN_OPTIONS
  enum listed_elsewhere: {
    listed_paid: 0,
    listed_free: 1,
    listed_mix: 2,
    not_listed: 3,
    listed_dont_know: 4
  }
  enum hired_status: {
    hired_tvs: 0,
    hired_other_free: 1,
    hired_paid: 2,
    hired_no_listing: 3,
    not_filled_ongoing: 4,
    not_filled_not_looking: 5,
    hired_dont_know: 6
  }

  belongs_to :publisher_user, class_name: 'User', optional: true
  belongs_to :school, optional: false
  belongs_to :subject, optional: true
  belongs_to :first_supporting_subject, class_name: 'Subject', optional: true
  belongs_to :second_supporting_subject, class_name: 'Subject', optional: true
  belongs_to :leadership, optional: true

  has_one :publish_feedback, class_name: 'VacancyPublishFeedback'

  has_many :documents

  delegate :name, to: :school, prefix: true, allow_nil: false
  delegate :geolocation, to: :school, prefix: true, allow_nil: true

  acts_as_gov_uk_date :starts_on, :ends_on, :publish_on,
                      :expires_on, error_clash_behaviour: :omit_gov_uk_date_field_error

  scope :applicable, (-> { applicable_by_date.or(applicable_by_time) })
  scope :applicable_by_time, (-> { where('expiry_time IS NOT NULL AND expiry_time >= ?', Time.zone.now) })
  scope :applicable_by_date, (-> { where('expiry_time IS NULL AND expires_on >= ?', Time.zone.today) })
  scope :active, (-> { where(status: %i[published draft]) })
  scope :listed, (-> { published.where('publish_on <= ?', Time.zone.today) })
  scope :published_on_count, (->(date) { published.where(publish_on: date.all_day).count })
  scope :pending, (-> { published.where('publish_on > ?', Time.zone.today) })
  scope :expired, (-> { expired_by_time.or(expired_by_date) })
  scope :expired_by_time, (-> { published.where('expiry_time IS NOT NULL AND expiry_time < ?', Time.zone.now) })
  scope :expired_by_date, (-> { published.where('expiry_time IS NULL AND expires_on < ?', Time.zone.today) })
  scope :live, (-> { live_by_date.or(live_by_time) })
  scope :live_by_time, (lambda {
                          published.where('expiry_time IS NOT NULL AND publish_on <= ? AND expiry_time >= ?',
                                          Time.zone.today, Time.zone.now)
                        })
  scope :live_by_date, (lambda {
                          published.where('expiry_time IS NULL AND publish_on <= ? AND expires_on >= ?',
                                          Time.zone.today, Time.zone.today)
                        })
  scope :awaiting_feedback, (-> { expired.where(listed_elsewhere: nil, hired_status: nil) })

  paginates_per 10

  validates :slug, presence: true

  before_save :update_flexible_working, if: :will_save_change_to_working_patterns_or_flexible_working?
  before_save :update_pro_rata_salary, if: :will_save_change_to_working_patterns?
  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at

  counter :page_view_counter
  counter :get_more_info_counter

  def location
    SchoolPresenter.new(school).location
  end

  def coordinates
    return if school_geolocation.nil?

    {
      lat: school_geolocation.x.to_f,
      lon: school_geolocation.y.to_f
    }
  end

  def listed?
    published? && !publish_on.future? && expires_on.future?
  end

  def as_indexed_json(_arg = {})
    as_json(
      methods: %i[coordinates],
      include: {
        school: { methods: %i[region_name], only: %i[phase name postcode address town county local_authority] },
        subject: { only: %i[name] },
        first_supporting_subject: { only: %i[name] },
        second_supporting_subject: { only: %i[name] }
      }
    )
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
      Rails.logger.debug('Validation error: Invalid application link format')
    end
    super(value)
  end

  def refresh_slug
    self.slug = nil
    send(:set_slug)
  end

  def flexible_working?
    return flexible_working unless flexible_working.nil?

    derived_flexible_working?
  end

  def attributes
    super().merge('working_patterns' => working_patterns)
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
    self.documents.each { |document| DocumentDelete.new(document).delete }
  end

  private

  def expires_at
    return nil if self.expires_on.blank? && self.expiry_time.blank?
    # rubocop:disable Rails/Date
    self.expiry_time.presence || Time.zone.at(self.expires_on.to_time).to_datetime.end_of_day
    # rubocop:enable Rails/Date
  end

  def slug_candidates
    [
      :job_title,
      %i[job_title school_name],
      %i[job_title location],
    ]
  end

  def derived_flexible_working?
    working_patterns.select { |working_pattern| FLEXIBLE_WORKING_PATTERN_OPTIONS.key?(working_pattern) }.any?
  end

  def will_save_change_to_working_patterns_or_flexible_working?
    will_save_change_to_working_patterns? || will_save_change_to_flexible_working?
  end

  def update_flexible_working
    return if skip_update_callbacks?
    return if flexible_working.nil?

    self.flexible_working = nil if flexible_working == derived_flexible_working?
  end

  def update_pro_rata_salary
    return if skip_update_callbacks?

    self.pro_rata_salary = nil if pro_rata_salary.blank?

    return if pro_rata_salary.nil?

    self.pro_rata_salary = working_patterns == ['part_time'] ? true : nil
  end

  def on_expired_vacancy_feedback_submitted_update_stats_updated_at
    return unless listed_elsewhere_changed? && hired_status_changed?

    self.stats_updated_at = Time.zone.now
  end
end
