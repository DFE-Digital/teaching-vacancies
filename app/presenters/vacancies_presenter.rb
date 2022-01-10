class VacanciesPresenter < BasePresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper
  attr_accessor :decorated_collection

  def initialize(vacancies)
    self.decorated_collection = vacancies.map { |v| VacancyPresenter.new(v) }
    super(vacancies)
  end

  def each(&)
    decorated_collection.each(&)
  end

  def any?
    decorated_collection.count.nonzero?
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
    }
  end
end
