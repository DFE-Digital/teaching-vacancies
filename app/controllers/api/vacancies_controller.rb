class Api::VacanciesController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show index]
  after_action :trigger_api_queried_event

  MAX_API_RESULTS_PER_PAGE = 100

  def index
    @pagy, @vacancies = pagy(vacancies, items: MAX_API_RESULTS_PER_PAGE, overflow: :empty_page)

    respond_to(&:json)
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
    event = DfE::Analytics::Event.new
      .with_type(:api_queried)
      .with_request_details(request)
      .with_response_details(response)
      .with_user(current_user)
      .with_data(event_data)

    DfE::Analytics::SendEvents.do([event])
  end
end
