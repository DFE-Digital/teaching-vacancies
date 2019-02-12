class Api::VacanciesController < Api::ApplicationController
  before_action :verify_json_request, only: %w[show index]

  def index
    records = Vacancy.includes(school: [:region]).listed.published.page(page_number)
    @vacancies = VacanciesPresenter.new(records, searched: false)

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
