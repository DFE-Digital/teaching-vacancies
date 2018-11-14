class Api::VacanciesController < Api::ApplicationController
  before_action :verify_json_request, only: %w[show]
  before_action :verify_json_or_csv_request, only: %w[index]

  def index
    records = Vacancy.listed.where.not(status: :draft).where.not(status: :trashed)
    @vacancies = VacanciesPresenter.new(records, searched: false)

    respond_to do |format|
      format.csv { send_data @vacancies.to_csv, filename: "#{Time.zone.now.iso8601}_jobs.csv", template: false }
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
end
