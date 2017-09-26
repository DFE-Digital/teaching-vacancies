require 'elasticsearch/model'

class Vacancy < ApplicationRecord
  include ApplicationHelper

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  index_name [Rails.env, model_name.collection.gsub(%r{/}, '-')].join('_')

  mappings dynamic: 'false' do
    indexes :job_title, analyzer: 'english'
    indexes :headline, analyzer: 'english'
    indexes :job_description, analyzer: 'english'

    indexes :school do
      indexes :phase, type: :keyword
    end

    indexes :expires_on, type: :date
    indexes :starts_on, type: :date
    indexes :updated_at, type: :date
    indexes :status, type: :keyword
    indexes :working_pattern, type: :keyword
  end

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  enum status: %i[published draft trashed]
  enum working_pattern: %i[full_time part_time]

  belongs_to :school, required: true
  belongs_to :subject
  belongs_to :pay_scale
  belongs_to :leadership

  delegate :name, to: :school, prefix: true, allow_nil: false

  scope :applicable, (-> { where('expires_on >= ?', Time.zone.today) })

  paginates_per 10

  validates :job_title, :job_description, :headline, \
            :minimum_salary, :essential_requirements, :working_pattern, \
            :publish_on, :expires_on, :slug, \
            presence: true

  def location
    [school.name, school.town, school.county].reject(&:blank?).join(', ')
  end

  def salary_range
    return number_to_currency(minimum_salary) if maximum_salary.blank?
    number_to_currency(minimum_salary) +
      ' - ' +
      number_to_currency(maximum_salary)
  end

  private def slug_candidates
    [
      :job_title,
      %i[job_title school_name],
      %i[job_title location],
    ]
  end

  def expired?
    expires_on < Time.zone.today
  end

  def self.public_search(filters:, sort:)
    query = VacancySearchBuilder.new(filters: filters, sort: sort).call
    ElasticSearchFinder.new.call(query[:search_query], query[:search_sort])
  end

  def as_indexed_json(_ = {})
    as_json(include: { school: { only: [:phase] } })
  end
end
