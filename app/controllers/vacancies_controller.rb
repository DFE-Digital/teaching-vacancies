class VacanciesController < ApplicationController
  def index
    @vacancies = Vacancy.applicable.published
  end
end
