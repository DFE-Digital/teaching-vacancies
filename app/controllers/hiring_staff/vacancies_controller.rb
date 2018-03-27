class HiringStaff::VacanciesController < HiringStaff::Vacancies::ApplicationController
  def index
    @vacancies = school.vacancies.all
  end

  def show
    vacancy = school.vacancies.published.find(id)
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
    @vacancy = school.vacancies.find(id)
    @vacancy.destroy

    redirect_to school_path, notice: 'Your vacancy was deleted.'
  end

  def summary
    vacancy = school.vacancies.published.find(id)
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def id
    params.require(:id)
  end

  def vacancy_id
    params.require(:vacancy_id)
  end
end
