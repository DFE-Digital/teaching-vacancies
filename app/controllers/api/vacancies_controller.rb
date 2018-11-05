class Api::VacanciesController < Api::ApplicationController
  before_action :verify_json_request

  def index
    filters = VacancyFilters.new({})
    records = Vacancy.public_search(filters: filters, sort: {}).records
    @vacancies = VacanciesPresenter.new(records, searched: false)
  end

  def show
    vacancy = Vacancy.listed.friendly.find(id)
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def id
    params[:id]
  end

  def set_headers
    response.set_header('X-Robots-Tag', 'noarchive')
  end

  def verify_json_request
    not_found unless request.format.json?
  end
end
