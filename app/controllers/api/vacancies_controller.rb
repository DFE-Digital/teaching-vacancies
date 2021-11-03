class Api::VacanciesController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show index]
  after_action :trigger_api_queried_event

  MAX_API_RESULTS_PER_PAGE = 100

  def index
    records = Vacancy.includes(organisation_vacancies: :organisation)
                     .live
                     .page(page_number)
                     .per(MAX_API_RESULTS_PER_PAGE)
                     .order(publish_on: :desc)
    @vacancies = VacanciesPresenter.new(records)

    respond_to do |format|
      format.json
    end
  end

  def show
    vacancy = Vacancy.listed.friendly.find(id)
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def trigger_api_queried_event
    Rollbar.debug("28 in controller")
    request_event.trigger(:api_queried)
  end

  def id
    params[:id]
  end

  def page_number
    params[:page] || 1
  end
end
