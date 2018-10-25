class HiringStaff::VacanciesController < HiringStaff::Vacancies::ApplicationController
  def show
    vacancy = school.vacancies.active.find(id)
    unless vacancy.published?
      return redirect_to school_job_review_path(vacancy.id),
                         alert: I18n.t('messages.jobs.view.only_published')
    end
    @get_information_count = vacancy.activities.where(key: 'vacancy.get_more_information').count
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def new
    reset_session_vacancy!
    redirect_to job_specification_school_job_path
  end

  def edit
    vacancy = school.vacancies.find(id)
    redirect_to school_job_review_path(vacancy.id) unless vacancy.published?

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def review
    vacancy = school.vacancies.active.find(vacancy_id)
    if vacancy.published?
      redirect_to school_job_path(vacancy.id),
                  notice: t('messages.vacancies.already_published')
    end

    session[:current_step] = :review
    store_vacancy_attributes(vacancy.attributes.compact)

    @vacancy = VacancyPresenter.new(vacancy)

    @vacancy.valid? if params[:source]&.eql?('publish')
  end

  def destroy
    @vacancy = school.vacancies.active.find(id)
    @vacancy.trash!
    remove_google_index(@vacancy)
    Auditor::Audit.new(@vacancy, 'vacancy.delete', current_session_id).log

    redirect_to school_path, notice: t('messages.jobs.delete')
  end

  def summary
    vacancy = school.vacancies.published.find(vacancy_id)
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def id
    params.require(:id)
  end

  def vacancy_id
    params.require(:job_id)
  end
end
