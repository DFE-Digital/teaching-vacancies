require 'elasticsearch/model'
require 'auditor'

class Vacancy < ApplicationRecord
  include ApplicationHelper
  include Auditor::Model

  include VacancyJobSpecificationValidations
  include VacancyCandidateSpecificationValidations
  include VacancyApplicationDetailValidations

  include Elasticsearch::Model

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
        indexes :address, type: :text
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
      indexes :working_pattern, type: :keyword
      indexes :minimum_salary, type: :integer
      indexes :maximum_salary, type: :integer
      indexes :coordinates, type: :geo_point, ignore_malformed: true
      indexes :newly_qualified_teacher, type: :boolean
    end
  end

  extend FriendlyId

  friendly_id :slug_candidates, use: %w[slugged history]

  enum status: %i[published draft trashed]
  enum working_pattern: %i[full_time part_time]

  belongs_to :school, required: true
  belongs_to :subject, required: false
  belongs_to :first_supporting_subject, class_name: 'Subject', required: false
  belongs_to :second_supporting_subject, class_name: 'Subject', required: false
  belongs_to :min_pay_scale, class_name: 'PayScale', required: false
  belongs_to :max_pay_scale, class_name: 'PayScale', required: false
  belongs_to :leadership, required: false

  has_one :feedback

  delegate :name, to: :school, prefix: true, allow_nil: false
  delegate :geolocation, to: :school, prefix: true, allow_nil: true

  acts_as_gov_uk_date :starts_on, :ends_on, :publish_on, :expires_on

  scope :applicable, (-> { where('expires_on >= ?', Time.zone.today) })
  scope :active, (-> { where(status: %i[published draft]) })
  scope :listed, (-> { published.where('publish_on <= ?', Time.zone.today) })
  scope :published_on_count, (->(date) { published.where('date(publish_on) = ?', date).count })

  paginates_per 10

  validates :slug, presence: true

  after_commit on: %i[create update] do
    __elasticsearch__.index_document
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

  def self.public_search(filters:, sort:)
    query = VacancySearchBuilder.new(filters: filters, sort: sort).call
    results = ElasticSearchFinder.new.call(query[:search_query], query[:search_sort])

    Rollbar.log(:info, 'A search returned 0 results', filters.to_hash) if results.count.zero?
    results
  end

  def listed?
    published? && !publish_on.future? && expires_on.future?
  end

  # rubocop:disable Naming/UncommunicativeMethodParamName
  def as_indexed_json(_ = {})
    as_json(
      methods: %i[coordinates],
      include: {
        school: { only: %i[phase name postcode address town] },
        subject: { only: %i[name] },
        first_supporting_subject: { only: %i[name] },
        second_supporting_subject: { only: %i[name] }
      }
    )
  end
  # rubocop:enable Naming/UncommunicativeMethodParamName

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

  def to_row
    [
      id,
      slug,
      created_at,
      status,
      publish_on,
      expires_on,
      starts_on,
      ends_on,
      weekly_hours,
      flexible_working,
      school.urn,
      school.county
    ]
  end

  private

  def slug_candidates
    [
      :job_title,
      %i[job_title school_name],
      %i[job_title location],
    ]
  end
end
