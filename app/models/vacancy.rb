require 'auditor'

class Vacancy < ApplicationRecord
  JOB_ROLE_OPTIONS = {
    teacher: 0,
    leadership: 1,
    sen_specialist: 2,
    nqt_suitable: 3
  }.freeze

  WORKING_PATTERN_OPTIONS = {
    full_time: 0,
    part_time: 100,
    job_share: 101
    # Legacy vacancies can have these options too
    # compressed_hours: 102,
    # staggered_hours: 103
  }.freeze

  JOB_SORTING_OPTIONS = [
    [I18n.t('jobs.sort_by.most_relevant'), ''],
    [I18n.t('jobs.sort_by.publish_on.descending'), 'publish_on_desc'],
    [I18n.t('jobs.sort_by.expiry_time.descending'), 'expiry_time_desc'],
    [I18n.t('jobs.sort_by.expiry_time.ascending'), 'expiry_time_asc'],
  ].freeze

  JOB_LOCATION_OPTIONS = {
    at_one_school: 0,
    at_multiple_schools: 1,
    central_office: 2,
  }.freeze

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
    live.includes(organisation_vacancies: :organisation).algolia_reindex!
  end

  def self.reindex
    live.includes(organisation_vacancies: :organisation).algolia_reindex
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
    unindexed.update_all(initially_indexed: true)
  end

  # I'm excluding expires_on from the where clause as expiry_time seems to be exactly tracking it-as expected.
  # TODO: remove expires_on completely from the attributes and only use expiry_time. Ticket to follow.
  def self.remove_vacancies_that_expired_yesterday!
    expired_records = where('expiry_time BETWEEN ? AND ?', Time.zone.yesterday.midnight, Time.zone.today.midnight)
    index.delete_objects(expired_records.map(&:id)) if expired_records.present?
  end

  algoliasearch auto_index: true, auto_remove: true, if: :listed? do
    attributes :education_phases, :job_roles, :job_title, :parent_organisation_name, :salary, :subjects, :working_patterns, :_geoloc

    attribute :expires_at do
      expires_at = format_date(expires_on)
      unless expiry_time.nil?
        expires_at + ' at ' + expiry_time.strftime('%-l:%M %P')
      end
    end

    attribute :expires_at_timestamp do
      expires_at.to_i
    end

    attribute :job_roles_for_display do
      VacancyPresenter.new(self).show_job_roles
    end

    attribute :job_summary do
      job_summary&.truncate(256)
    end

    attribute :last_updated_at do
      # Convert from ActiveSupport::TimeWithZone object to Unix time
      updated_at.to_i
    end

    attribute :listing_status do
      status
    end

    attribute :organisations do
      { names: organisations.map(&:name),
        counties: organisations.map(&:county).uniq,
        detailed_school_types: organisations.map { |org|
                                org.detailed_school_type if org.is_a?(School)
                               } .reject(&:blank?).uniq,
        group_type: organisations.map { |org| org.group_type if org.is_a?(SchoolGroup) }.reject(&:blank?).uniq,
        religious_characters: organisations.map { |org| org.religious_character if org.is_a?(School) }.reject(&:blank?)
                                           .uniq,
        regions: organisations.map { |org| org.region if org.is_a?(School) }.reject(&:blank?).uniq,
        school_types: organisations.map { |org|
                        org.school_type&.singularize if org.is_a?(School)
                      } .reject(&:blank?).uniq,
        towns: organisations.map(&:town).uniq }
    end

    attribute :permalink do
      slug
    end

    attribute :publication_date do
      publish_on&.to_s
    end

    attribute :publication_date_timestamp do
      publish_on&.to_time&.to_i
    end

    attribute :start_date do
      starts_on&.to_s
    end

    attribute :start_date_timestamp do
      starts_on&.to_time&.to_i
    end

    attribute :subjects_for_display do
      VacancyPresenter.new(self).show_subjects
    end

    attribute :working_patterns_for_display do
      VacancyPresenter.new(self).working_patterns
    end

    attributesForFaceting %i[job_roles working_patterns education_phases listing_status]

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

  def _geoloc
    organisations.map { |organisation|
      if organisation.geolocation.present?
        { lat: organisation.geolocation.x.to_f, lng: organisation.geolocation.y.to_f }
      end
    }.reject(&:blank?).presence
  end

  extend FriendlyId
  extend ArrayEnum

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
  belongs_to :subject, optional: true
  belongs_to :first_supporting_subject, class_name: 'Subject', optional: true
  belongs_to :second_supporting_subject, class_name: 'Subject', optional: true
  belongs_to :leadership, optional: true

  has_one :publish_feedback, class_name: 'VacancyPublishFeedback'

  has_many :documents

  has_many :organisation_vacancies, dependent: :destroy
  has_many :organisations, through: :organisation_vacancies
  accepts_nested_attributes_for :organisation_vacancies

  delegate :name, to: :parent_organisation, prefix: true, allow_nil: true

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
  scope :in_central_office, (-> { where(job_location: 'central_office') })
  scope :in_organisation_ids, lambda { |ids|
    joins(:organisation_vacancies).where(organisation_vacancies: { organisation_id: ids }).distinct
  }

  paginates_per 10

  validates :slug, presence: true

  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at

  counter :page_view_counter
  counter :get_more_info_counter

  def organisation
    organisation_vacancies.first&.organisation
  end

  def location
    [organisation&.name, organisation&.town, organisation&.county].reject(&:blank?)
  end

  def coordinates
    return if organisation&.geolocation.nil?

    {
      lat: organisation.geolocation.x.to_f,
      lon: organisation.geolocation.y.to_f
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
        organisation: { only: %i[region phase name postcode address town county local_authority] },
        subject: { only: %i[name] },
        first_supporting_subject: { only: %i[name] },
        second_supporting_subject: { only: %i[name] }
      },
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

  def attributes
    super().merge('working_patterns' => working_patterns, 'job_roles' => job_roles)
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

  def parent_organisation
    organisations.many? ? organisations.first.school_groups.first : organisation
  end

  def education_phases
    organisations.map(&:readable_phases).flatten.uniq
  end

private

  def expires_at
    return nil if expires_on.blank? && expiry_time.blank?

    expiry_time.presence || Time.zone.at(expires_on.to_time).to_time.end_of_day
  end

  def slug_candidates
    [
      :job_title,
      %i[job_title parent_organisation_name],
      %i[job_title location],
    ]
  end

  def on_expired_vacancy_feedback_submitted_update_stats_updated_at
    return unless listed_elsewhere_changed? && hired_status_changed?

    self.stats_updated_at = Time.zone.now
  end
end
