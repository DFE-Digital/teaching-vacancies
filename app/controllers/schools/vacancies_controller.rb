class Schools::VacanciesController < HiringStaff::Vacancies::ApplicationController
  def new
    reset_session_vacancy!
    redirect_to job_specification_school_vacancy_path(school_id: school.id)
  end

  def review
    vacancy = school.vacancies.find(vacancy_id)
    redirect_to vacancy_path(vacancy), notice: 'This vacancy has already been published' if vacancy.published?

    session[:current_step] = :review
    store_vacancy_attributes(vacancy.attributes.compact)

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def show
    vacancy = school.vacancies.published.find(params[:id])
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def vacancy_params
    params.permit(:vacancy_id)
  end

  def vacancy_id
    vacancy_params[:vacancy_id]
  end
end
