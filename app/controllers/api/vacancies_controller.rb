class Api::VacanciesController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show index]
  after_action :trigger_api_queried_event

  MAX_API_RESULTS_PER_PAGE = 100

  def index
    @pagy, @vacancies = pagy(vacancies, items: MAX_API_RESULTS_PER_PAGE)

    respond_to do |format|
      format.json
    end
  end

  def show
    vacancy = Vacancy.listed.friendly.find(params[:id])
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def vacancies
    Vacancy.includes(:organisations).live.order(publish_on: :desc)
  end

  def trigger_api_queried_event(event_data = {})
    request_event.trigger(:api_queried, event_data)
  end
end
