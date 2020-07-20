class VacanciesPresenter < BasePresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper
  attr_accessor :decorated_collection
  attr_reader :searched, :total_count, :coordinates
  alias_method :user_search?, :searched

  def initialize(vacancies, searched:, total_count:, coordinates: '')
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

  def search_heading(keyword: '', location: '')
    if keyword.present? && location.present?
      I18n.t('jobs.search_result_heading.keyword_location_html',
        jobs_count: number_with_delimiter(total_count), location: location, keyword: keyword, count: total_count)
    elsif keyword.present?
      I18n.t('jobs.search_result_heading.keyword_html',
        jobs_count: number_with_delimiter(total_count), keyword: keyword, count: total_count)
    elsif location.present?
      I18n.t('jobs.search_result_heading.location_html',
        jobs_count: number_with_delimiter(total_count), location: location, count: total_count)
    else
      I18n.t('jobs.search_result_heading.without_search_html',
        jobs_count: number_with_delimiter(total_count), count: total_count)
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
end
