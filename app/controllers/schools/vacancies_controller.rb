class Schools::VacanciesController < ApplicationController
  def new
    redirect_to job_specification_school_vacancy_path(school_id: school.id)
  end

  def review
    vacancy  = school.vacancies.find(vacancy_id)
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def publish
    vacancy = Vacancy.find(vacancy_id)
    if PublishVacancy.new(vacancy: vacancy).call
      session[:vacancy_attributes] = nil
      redirect_to vacancy_path(vacancy), notice: 'The vacancy is now available'
    else
      redirect_to review_school_vacancy_path(school_id: school.id, vacancy_id: vacancy.id),
                  notice: 'We were unable to publish your vacancy. Please try again.'
    end
  end

  private

  def school
    @school ||= School.find_by!(id: school_id)
  end

  def school_id
    params.permit(:school_id)[:school_id]
  end

  def vacancy_id
    params.permit![:vacancy_id]
  end
end
