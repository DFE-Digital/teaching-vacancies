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
    [I18n.t('jobs.sort_by.expiry_time.descending'), 'expiry_time_desc'],
    [I18n.t('jobs.sort_by.expiry_time.ascending'), 'expiry_time_asc']
  ]

  JOB_LOCATION_OPTIONS = [
    [I18n.t('helpers.fieldset.job_location_form.job_location_options.at_one_school'), 'at_one_school'],
    [I18n.t('helpers.fieldset.job_location_form.job_location_options.central_office'), 'central_office']
  ]

  include ApplicationHelper
  include Auditor::Model
  include DatesHelper
  include VacancyJobSpecificationValidations
  include VacancyPayPackageValidations
  include VacancyImportantDateValidations
  include VacancyApplicationDetailValidations
  include VacancyJobSummaryValidations

  include Redis::Objects

  # For guidance on sanity-checking an indexing change, read documentation/algolia_sanity_check.md
  include AlgoliaSearch

  # NOTE: the `if: :listed?` filter in the `algoliasearch` stanza below *only* excludes records from being *added* to
  # the index. It DOES NOT prevent the ruby client from checking that the record exists in the Algolia index in the
  # first place. Even if the record should not be in the index (unpublished or expired records), the client still
  # consumes an Algolia operation to try and look it up if it appears in canonical list of records returned by the
  # model.
  #
  # To illustrate: if you run the unmodified `Vacancy.reindex!` on a recent (2020-06-18) production dataset you will
  # consume more than 30,000 operations on the Algolia app. This occurs because it looks up each of the 30,000+
  # expired/unpublished records before it applies the `:listed?` filter. It only indexes about 470 records. I am not
  # 100% certain, but it seems this is done so it can remove records that should not be in the index according to the
  # filter.
  #
  # If, however, you run `Vacancy.live.reindex!`, which scopes the list to only the "published" records, it only
  # consumes slightly more operation than there are indexable records.
  def self.reindex!
    live.algolia_reindex!
  end

  def self.reindex
    live.algolia_reindex
  end

  # This is intended as a one-shot method used in conjuntion with `algolia_index...if: :listed?` to clear ununsed
  # records from the production db. It should be deleted after it is successfully run.
  def self.full_reindex!
    algolia_reindex!
  end

  # This is the main method you should use most of the time when bulk-adding new records to the algolia index. It will
  # not use any additional operations checking records that have been indexed once. NOTE: if a record has been indexed
  # already and it is updated with new or additional information, the `auto_index: true` will do the work of keeping the
  # changes in sync with the algolia index. This method is solely for preventing us paying for unnecessary usage when
  # adding records that have become `live` since the last time it was run.
  def self.update_index!
    unindexed.algolia_reindex!
    # rubocop:disable Rails/SkipsModelValidations
    unindexed.update_all(initially_indexed: true)
    # rubocop:enable Rails/SkipsModelValidations
  end

  # I'm excluding expires_on from the where clause as expiry_time seems to be exactly tracking it-as expected.
  # TODO: remove expires_on completely from the attributes and only use expiry_time. Ticket to follow.
  def self.remove_vacancies_that_expired_yesterday!
    expired_records = where('expiry_time BETWEEN ? AND ?', Time.zone.yesterday.midnight, Time.zone.today.midnight)
    index.delete_objects(expired_records.map(&:id)) if expired_records.present?
  end

  # rubocop:disable Metrics/BlockLength
  # rubocop:disable Metrics/LineLength
  algoliasearch auto_index: true, auto_remove: true, if: :listed? do
    attributes :location, :job_roles, :job_title, :salary, :subjects, :working_patterns

    attribute :expires_at do
      expires_at = format_date(self.expires_on)
      unless self.expiry_time.nil?
        expires_at + ' at ' + self.expiry_time.strftime('%-l:%M %P')
      end
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
        town: school.town } if school.present?
    end

    attribute :start_date do
      self.starts_on&.to_s
    end

    attribute :start_date_timestamp do
      self.starts_on&.to_datetime&.to_i
    end

    attribute :working_patterns_for_display do
      VacancyPresenter.new(self).working_patterns
    end

    geoloc :lat, :lng

    attributesForFaceting [:job_roles, :working_patterns, :school, :listing_status]

    add_replica 'Vacancy_publish_on_desc', inherit: true do
      ranking ['desc(publication_date_timestamp)']
    end

    add_replica 'Vacancy_expiry_time_desc', inherit: true do
      ranking ['desc(expires_at_timestamp)']
    end

    add_replica 'Vacancy_expiry_time_asc', inherit: true do
      ranking ['asc(expires_at_timestamp)']
    end
  end
  # rubocop:enable Metrics/LineLength
  # rubocop:enable Metrics/BlockLength

  def lat
    self.school.geolocation&.x&.to_f if school.present?
  end

  def lng
    self.school.geolocation&.y&.to_f if school.present?
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
  belongs_to :school, optional: true
  belongs_to :school_group, optional: true
  belongs_to :subject, optional: true
  belongs_to :first_supporting_subject, class_name: 'Subject', optional: true
  belongs_to :second_supporting_subject, class_name: 'Subject', optional: true
  belongs_to :leadership, optional: true

  has_one :publish_feedback, class_name: 'VacancyPublishFeedback'

  has_many :documents

  delegate :name, to: :school_or_school_group, prefix: true, allow_nil: true

  acts_as_gov_uk_date :starts_on, :publish_on,
    :expires_on, error_clash_behaviour: :omit_gov_uk_date_field_error

  scope :active, (-> { where(status: %i[published draft]) })
  scope :applicable, (-> { applicable_by_date.or(applicable_by_time) })
  scope :applicable_by_time, (-> { where('expiry_time IS NOT NULL AND expiry_time >= ?', Time.zone.now) })
  scope :applicable_by_date, (-> { where('expiry_time IS NULL AND expires_on >= ?', Time.zone.today) })
  scope :awaiting_feedback, (-> { expired.where(listed_elsewhere: nil, hired_status: nil) })
  scope :expired, (-> { expired_by_time.or(expired_by_date) })
  scope :expired_by_time, (-> { published.where('expiry_time IS NOT NULL AND expiry_time < ?', Time.zone.now) })
  scope :expired_by_date, (-> { published.where('expiry_time IS NULL AND expires_on < ?', Time.zone.today) })
  scope :listed, (-> { published.where('publish_on <= ?', Time.zone.today) })
  scope :live, (-> { live_by_date.or(live_by_time) })
  scope :live_by_time, (lambda {
    published.where('expiry_time IS NOT NULL AND publish_on <= ? AND expiry_time >= ?',
                    Time.zone.today, Time.zone.now)
  })
  scope :live_by_date, (lambda {
    published.where('expiry_time IS NULL AND publish_on <= ? AND expires_on >= ?',
                    Time.zone.today, Time.zone.today)
  })
  scope :pending, (-> { published.where('publish_on > ?', Time.zone.today) })
  scope :published_on_count, (->(date) { published.where(publish_on: date.all_day).count })
  scope :unindexed, (-> { live.where(initially_indexed: false) })
  scope :in_school_ids, (-> (ids) { where(school_id: ids) })
  scope :in_central_office, (-> { where(job_location: 'central_office') })

  paginates_per 10

  validates :slug, presence: true

  before_save :update_flexible_working, if: :will_save_change_to_working_patterns_or_flexible_working?
  before_save :update_pro_rata_salary, if: :will_save_change_to_working_patterns?
  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at

  counter :page_view_counter
  counter :get_more_info_counter

  def school_or_school_group
    school.presence || school_group.presence
  end

  def location
    [school_or_school_group&.name, school_or_school_group&.town, school_or_school_group&.county].reject(&:blank?)
  end

  def coordinates
    return if school&.geolocation.nil?

    {
      lat: school.geolocation.x.to_f,
      lon: school.geolocation.y.to_f
    }
  end

  # `publish_on` is nullable, so you can't use `!publish_on.try(:future?)` as `publish_on = nil` will yield an
  # unintended `true` result.
  #
  # I've deliberately chosen `#try` over `#&.` for long-term readability.
  def listed?
    published? && (publish_on.try(:today?) || publish_on.try(:past?)) && expiry_time.try(:future?)
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
      %i[job_title school_or_school_group_name],
      %i[job_title location]
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
