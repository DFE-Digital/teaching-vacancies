class Api::V2::VacanciesController < Api::ApplicationController
  def index
    # @vacancies = [vacancy]
    #
    # respond_to do |format|
    #   format.json
    # end
    @pagy, @vacancies = pagy(vacancies, items: 100, overflow: :empty_page)

    respond_to(&:json)
  end

  def create
    respond_to do |format|
      format.json
    end
  end

  def update
    @vacancy = VacancyPresenter.new vacancy
    respond_to do |format|
      format.json
    end
  end

  def destroy; end

  def show
    @vacancy = VacancyPresenter.new vacancy
  end

  private

  def vacancy
    FactoryBot.build(:vacancy)
  end

  def vacancies
    Vacancy.includes(:organisations).live.order(publish_on: :desc)
  end
end
