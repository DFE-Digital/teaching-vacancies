class Api::VacanciesController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show index]
  after_action :trigger_api_queried_event

  MAX_API_RESULTS_PER_PAGE = 100

  def index
    @vacancies = Vacancy.includes(:organisations)
                        .live
                        .page(page_number)
                        .per(MAX_API_RESULTS_PER_PAGE)
                        .order(publish_on: :desc)

    respond_to do |format|
      format.json
    end
  end

  def show
    vacancy = Vacancy.listed.friendly.find(id)
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def trigger_api_queried_event(event_data = {})
    request_event.trigger(:api_queried, event_data)
  end

  def id
    params[:id]
  end

  def page_number
    params[:page] || 1
  end
end
