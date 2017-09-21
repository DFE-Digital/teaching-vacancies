class VacanciesController < ApplicationController
  def index
    @vacancies = Vacancy.applicable.published.page(params[:page])
  end

  def show
    @vacancy = Vacancy.published.friendly.find(params[:id])
  end
end
