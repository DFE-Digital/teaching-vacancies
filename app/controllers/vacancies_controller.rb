class VacanciesController < ApplicationController
  def index
    @vacancies = Vacancy.applicable.published.page(params[:page])
  end
end
