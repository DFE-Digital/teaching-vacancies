class HiringStaff::VacanciesController < HiringStaff::Vacancies::ApplicationController
  before_action :set_vacancy, only: %i[review preview]

  def show
    vacancy = find_active_vacancy_by_id
    unless vacancy.published?
      return redirect_to school_job_review_path(vacancy.id),
                         notice: I18n.t('messages.jobs.view.only_published')
    end
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def new
    reset_session_vacancy!
    redirect_to job_specification_school_job_path
  end

  def edit
    vacancy = current_school.vacancies.find(id)
    return redirect_to school_job_review_path(vacancy.id) unless vacancy.published?

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def review
    return redirect_to school_job_path(@vacancy.id), notice: already_published_message if @vacancy.published?

    reset_session_vacancy!
    store_vacancy_attributes(@vacancy.attributes)

    unless @vacancy.valid?
      redirect_to_incomplete_step
    else
      set_completed_step
    end

    session[:current_step] = :review
    @vacancy = VacancyPresenter.new(@vacancy)
    @vacancy.valid? if params[:source]&.eql?('publish')
  end

  def destroy
    @vacancy = find_active_vacancy_by_id
    @vacancy.delete_documents
    @vacancy.trash!
    remove_google_index(@vacancy)
    Auditor::Audit.new(@vacancy, 'vacancy.delete', current_session_id).log

    redirect_to school_path, notice: t('messages.jobs.delete')
  end

  def preview
    return redirect_to school_job_path(@vacancy.id), notice: already_published_message if @vacancy.published?
    redirect_to_incomplete_step unless @vacancy.valid?
    @vacancy = VacancyPresenter.new(@vacancy)
  end

  def summary
    vacancy = current_school.vacancies.published.find(vacancy_id)
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
    valid = PayPackageForm.new(@vacancy.attributes).valid?
    clear_cache_and_step unless valid
    valid
  end

  def step_3_valid?
    valid = SupportingDocumentsForm.new(@vacancy.attributes).valid?
    clear_cache_and_step unless valid
    valid
  end

  def step_4_valid?
    valid = ApplicationDetailsForm.new(@vacancy.attributes).completed?
    clear_cache_and_step unless valid
    valid
  end

  def redirect_to_incomplete_step
    return redirect_to school_job_pay_package_path(@vacancy.id) unless step_2_valid?
    return redirect_to supporting_documents_school_job_path unless step_3_valid?
    return redirect_to application_details_school_job_path unless step_4_valid?
  end

  def already_published_message
    I18n.t('jobs.already_published')
  end

  def clear_cache_and_step
    flash.clear
    session[:current_step] = ''
  end

  def set_completed_step
    @vacancy.update(completed_step: current_step)
  end

  def find_active_vacancy_by_id
    current_school.vacancies.active.find(id)
  end
end
