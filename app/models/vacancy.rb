require 'elasticsearch/model'
require 'auditor'

class Vacancy < ApplicationRecord
  FLEXIBLE_WORKING_PATTERN_OPTIONS = {
    'part_time' => 100,
    'job_share' => 101,
    'compressed_hours' => 102,
    'staggered_hours' => 103
  }.freeze

  WORKING_PATTERN_OPTIONS = {
    'full_time' => 0
  }.merge(FLEXIBLE_WORKING_PATTERN_OPTIONS).freeze

  include ApplicationHelper
  include Auditor::Model

  include VacancyJobSpecificationValidations
  include VacancyCandidateSpecificationValidations
  include VacancyApplicationDetailValidations

  include Elasticsearch::Model
  include Redis::Objects

  index_name [Rails.env, model_name.collection.tr('\/', '-')].join('_')
  document_type 'vacancy'
  settings index: {
    analysis: {
      analyzer: {
        stopwords: {
          tokenizer: 'standard',
          filter: ['standard', 'lowercase', 'english_stopwords', 'stopwords']
        }
      },
      filter: {
        english_stopwords: {
          type: 'stop',
          stopwords: '_english_'
        },
        stopwords: {
          type: 'stop',
          stopwords: ['part', 'full', 'time']
        }
      }
    }
  } do
    mappings dynamic: 'false' do
      indexes :job_title, type: :text, analyzer: :stopwords
      indexes :job_description, analyzer: 'english'

      indexes :school do
        indexes :name, analyzer: 'english'
        indexes :phase, type: :keyword
        indexes :postcode, type: :text
        indexes :town, type: :text
        indexes :county, type: :text
        indexes :local_authority, type: :text
        indexes :address, type: :text
        indexes :region_name, type: :text
      end

      indexes :subject do
        indexes :name, type: :text
      end

      indexes :first_supporting_subject do
        indexes :name, type: :text
      end

      indexes :second_supporting_subject do
        indexes :name, type: :text
      end

      indexes :expires_on, type: :date
      indexes :starts_on, type: :date
      indexes :updated_at, type: :date
      indexes :publish_on, type: :date
      indexes :status, type: :keyword
      indexes :working_patterns, type: :keyword
      indexes :minimum_salary, type: :integer
      indexes :maximum_salary, type: :integer
      indexes :coordinates, type: :geo_point, ignore_malformed: true
      indexes :newly_qualified_teacher, type: :boolean
    end
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
  belongs_to :min_pay_scale, class_name: 'PayScale', optional: true
  belongs_to :max_pay_scale, class_name: 'PayScale', optional: true
  belongs_to :leadership, optional: true

  has_one :publish_feedback, class_name: 'VacancyPublishFeedback'

  has_many :document

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

  after_commit on: %i[create update] do
    __elasticsearch__.index_document
  end

  counter :page_view_counter
  counter :get_more_info_counter

  def self.public_search(filters:, sort:)
    query = VacancySearchBuilder.new(filters: filters, sort: sort).call
    results = ElasticSearchFinder.new.call(query[:search_query], query[:search_sort])

    Rollbar.log(:info, 'A search returned 0 results', filters.to_hash) if results.count.zero?
    results
  end

  def location
    @location ||= SchoolPresenter.new(school).location
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

  def minimum_salary=(salary)
    self[:minimum_salary] = format_salary(salary)
  end

  def maximum_salary=(salary)
    self[:maximum_salary] = format_salary(salary)
  end

  def weekly_hours?
    weekly_hours.present? && derived_flexible_working?
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

  private

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

  def format_salary(salary)
    salary = salary.to_s.strip
    return salary.delete(',') if salary[SalaryValidator::SALARY_FORMAT]

    salary
  end
end
