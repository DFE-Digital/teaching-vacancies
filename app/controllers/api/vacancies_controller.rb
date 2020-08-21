class Api::VacanciesController < Api::ApplicationController
  before_action :verify_json_request, only: %w[show index]

  MAX_API_RESULTS_PER_PAGE = 50

  def index
    records = Vacancy.includes(school: [:region])
                     .listed
                     .published
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

  def id
    params[:id]
  end

  def page_number
    params[:page] || 1
  end
end
