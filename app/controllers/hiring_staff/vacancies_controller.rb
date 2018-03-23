class HiringStaff::VacanciesController < HiringStaff::Vacancies::ApplicationController
  def index
    @school = find_school_from_params
    @vacancies = @school.vacancies.all
  end

  def show
    @school = find_school_from_params
    vacancy = @school.vacancies.published.find(params[:id])
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def new
    reset_session_vacancy!
    redirect_to job_specification_school_vacancy_path(school_id: school.id)
  end

  def review
    vacancy = school.vacancies.find(vacancy_id)
    if vacancy.published?
      redirect_to school_vacancy_path(school_id: school.id, id: vacancy.id),
                  notice: t('vacancies.already_published')
    end

    session[:current_step] = :review
    store_vacancy_attributes(vacancy.attributes.compact)

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def destroy
    @school = find_school_from_params
    @vacancy = find_vacancy_from_params
    @vacancy.destroy

    redirect_to school_vacancies_path, notice: 'Your vacancy was deleted.'
  end

  private

  def vacancy_id
    params.require(:vacancy_id)
  end

  def find_vacancy_from_params(school)
    @vacancy ||= school.vacancies.find(vacancy_id)
  end

  def find_school_from_params
    @school ||= School.find(school_id)
  end
end
