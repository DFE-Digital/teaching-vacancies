require 'elasticsearch/model'
require 'auditor'

class Vacancy < ApplicationRecord
  include ApplicationHelper
  include Auditor::Model

  include VacancyJobSpecificationValidations
  include VacancyCandidateSpecificationValidations
  include VacancyApplicationDetailValidations

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name [Rails.env, model_name.collection.tr('\/', '-')].join('_')

  mappings dynamic: 'false' do
    indexes :job_title, type: :string, analyzer: 'english'
    indexes :job_description, analyzer: 'english'

    indexes :school do
      indexes :name, analyzer: 'english'
      indexes :phase, type: :keyword
      indexes :postcode, type: :string
      indexes :town, type: :string
      indexes :county, type: :string
      indexes :address, type: :string
    end

    indexes :subject do
      indexes :name, type: :string
    end

    indexes :expires_on, type: :date
    indexes :starts_on, type: :date
    indexes :updated_at, type: :date
    indexes :publish_on, type: :date
    indexes :status, type: :keyword
    indexes :working_pattern, type: :keyword
    indexes :minimum_salary, type: :string
    indexes :maximum_salary, type: :string
  end

  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged

  enum status: %i[published draft trashed]
  enum working_pattern: %i[full_time part_time]

  belongs_to :school, required: true
  belongs_to :subject, required: false
  belongs_to :pay_scale, required: false
  belongs_to :leadership, required: false

  delegate :name, to: :school, prefix: true, allow_nil: false
  delegate :geolocation, to: :school, prefix: true, allow_nil: true

  acts_as_gov_uk_date :starts_on, :ends_on, :publish_on, :expires_on

  scope :applicable, (-> { where('expires_on >= ?', Time.zone.today) })
  scope :active, (-> { where(status: %i[published draft]) })

  paginates_per 10

  validates :slug, presence: true

  def location
    @location ||= SchoolPresenter.new(school).location
  end

  def self.public_search(filters:, sort:)
    query = VacancySearchBuilder.new(filters: filters, sort: sort).call
    ElasticSearchFinder.new.call(query[:search_query], query[:search_sort])
  end

  def as_indexed_json(_ = {})
    as_json(
      include: {
        school: { only: %i[phase postcode name town county address] },
        subject: { only: %i[name] }
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
    value = Addressable::URI.heuristic_parse(value).to_s
    super(value)
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
