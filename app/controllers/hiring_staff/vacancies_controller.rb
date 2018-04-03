class HiringStaff::VacanciesController < HiringStaff::Vacancies::ApplicationController
  def show
    vacancy = school.vacancies.active.find(id)
    unless vacancy.published?
      return redirect_to school_vacancy_review_path(school, vacancy.id),
                         notice: I18n.t('vacancies.view.only_published')
    end
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def new
    reset_session_vacancy!
    redirect_to job_specification_school_vacancy_path(school)
  end

  def edit
    vacancy = school.vacancies.find(id)
    redirect_to school_vacancy_review_path(school, vacancy.id) unless vacancy.published?

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def review
    vacancy = school.vacancies.active.find(vacancy_id)
    if vacancy.published?
      redirect_to school_vacancy_path(school_id: school.id, id: vacancy.id),
                  notice: t('vacancies.already_published')
    end

    session[:current_step] = :review
    store_vacancy_attributes(vacancy.attributes.compact)

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def destroy
    @vacancy = school.vacancies.active.find(id)
    @vacancy.trash!

    redirect_to school_path, notice: t('messages.vacancies.delete')
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
