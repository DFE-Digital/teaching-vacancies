class VacanciesPresenter < BasePresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper
  attr_accessor :decorated_collection
  attr_reader :searched, :total_count
  alias_method :user_search?, :searched

  CSV_ATTRIBUTES = %w[title description salary jobBenefits datePosted educationRequirements qualifications
                      experienceRequirements employmentType jobLocation.addressLocality
                      jobLocation.addressRegion jobLocation.streetAddress jobLocation.postalCode url
                      hiringOrganization.type hiringOrganization.name hiringOrganization.identifier].freeze

  def initialize(vacancies, searched:, total_count:)
    self.decorated_collection = vacancies.map { |v| VacancyPresenter.new(v) }
    @searched = searched
    @total_count = total_count
    super(vacancies)
  end

  def each(&block)
    decorated_collection.each(&block)
  end

  def any?
    decorated_collection.count.nonzero?
  end

  def total_count_message
    if total_count == 1
      return I18n.t('jobs.job_count_without_search', count: total_count) unless @searched

      I18n.t('jobs.job_count', count: total_count)
    else
      return I18n.t('jobs.job_count_plural_without_search', count: number_with_delimiter(total_count)) unless @searched

      I18n.t('jobs.job_count_plural', count: number_with_delimiter(total_count))
    end
  end

  def total_count_message_with_location(location)
    return I18n.t('jobs.job_count_with_location_category', count: total_count, location: location) if total_count == 1
    I18n.t('jobs.job_count_plural_with_location_category', \
      count: number_with_delimiter(total_count), location: location)
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << CSV_ATTRIBUTES
      decorated_collection.map { |vacancy| csv << to_csv_row(vacancy) }
    end
  end

  def current_api_url
    api_jobs_url(json_api_params.merge(page: model.current_page))
  end

  def first_api_url
    api_jobs_url(json_api_params.merge(page: 1))
  end

  def last_api_url
    api_jobs_url(json_api_params.merge(page: model.total_pages))
  end

  def previous_api_url
    api_jobs_url(json_api_params.merge(page: model.prev_page)) if model.prev_page
  end

  def next_api_url
    api_jobs_url(json_api_params.merge(page: model.next_page)) if model.next_page
  end

  private

  def json_api_params
    {
      format: :json,
      api_version: 1,
      protocol: 'https'
    }
  end

  # rubocop:disable Metrics/AbcSize
  def to_csv_row(vacancy)
    [vacancy.job_title,
     vacancy.job_summary,
     vacancy.salary,
     vacancy.benefits,
     vacancy.publish_on.to_time.iso8601,
     vacancy.education,
     vacancy.qualifications,
     vacancy.experience,
     vacancy.working_patterns_for_job_schema,
     vacancy.school.town,
     vacancy.school&.region&.name,
     vacancy.school.address,
     vacancy.school.postcode,
     job_url(vacancy, protocol: 'https'),
     'School',
     vacancy.school.name,
     vacancy.school.urn]
  end
  # rubocop:enable Metrics/AbcSize
end
