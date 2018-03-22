class Schools::VacanciesController < ApplicationController
  def new
    redirect_to job_specification_school_vacancy_path(school_id: school.id)
  end

  def review
    vacancy = school.vacancies.find(vacancy_id)
    redirect_to vacancy_path(vacancy), notice: 'This vacancy has already been published' if vacancy.published?

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def show
    vacancy = school.vacancies.published.find(params[:id])
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def school
    @school ||= School.find_by!(id: school_id)
  end

  def school_id
    vacancy_params[:school_id]
  end

  def vacancy_params
    params.permit(:school_id, :vacancy_id)
  end

  def vacancy_id
    vacancy_params[:vacancy_id]
  end
end
