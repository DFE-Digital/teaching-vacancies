class HiringStaff::VacanciesController < HiringStaff::Vacancies::ApplicationController
  before_action :set_vacancy, only: %i[review]

  def show
    vacancy = school.vacancies.active.find(id)
    unless vacancy.published?
      return redirect_to school_job_review_path(vacancy.id),
                         alert: I18n.t('messages.jobs.view.only_published')
    end
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
    return redirect_to school_job_path(@vacancy.id), notice: already_published_message if @vacancy.published?

    unless @vacancy.valid?
      return redirect_to candidate_specification_school_job_path unless step_2_valid?
      return redirect_to application_details_school_job_path unless step_3_valid?
    end

    session[:current_step] = :review
    store_vacancy_attributes(@vacancy)
    @vacancy = VacancyPresenter.new(@vacancy)
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

  def step_2_valid?
    valid = CandidateSpecificationForm.new(@vacancy.attributes).completed?
    clear_cache_and_step unless valid
    valid
  end

  def step_3_valid?
    valid = ApplicationDetailsForm.new(@vacancy.attributes).completed?
    clear_cache_and_step unless valid
    valid
  end

  def already_published_message
    I18n.t('messages.vacancies.already_published')
  end

  def clear_cache_and_step
    flash.clear
    session[:vacancy_attributes] = @vacancy.attributes if vacancy_is_not_in_current_session?
  end

  def vacancy_is_not_in_current_session?
    return session[:vacancy_attributes].nil? 
    # session[:vacancy_attributes]['id'] =! @vacancy.id
  end

  def set_vacancy
    @vacancy = school.vacancies.active.find(vacancy_id)
  end
end
