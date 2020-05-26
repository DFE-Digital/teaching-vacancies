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

    vacancy.update(state: 'edit_published') unless vacancy&.state == 'edit_published'
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def review
    return redirect_to school_job_path(@vacancy.id), notice: I18n.t('jobs.already_published') if @vacancy.published?

    reset_session_vacancy!
    store_vacancy_attributes(@vacancy.attributes)

    unless @vacancy.valid?
      redirect_to_incomplete_step
    else
      state = params[:edit_draft] == 'true' ? 'edit' : 'review'
      @vacancy.update(state: state) unless @vacancy&.state == state
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

    redirect_to school_path, success: t('messages.jobs.delete')
  end

  def preview
    return redirect_to school_job_path(@vacancy.id), notice: I18n.t('jobs.already_published') if @vacancy.published?
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

  def step_valid?(step_form)
    validation = step_form.new(@vacancy.attributes)
    if step_form == ApplicationDetailsForm
      (validation&.completed?).tap { |valid| clear_cache_and_step unless valid }
    else
      (validation&.valid?).tap { |valid| clear_cache_and_step unless valid }
    end
  end

  def redirect_to_incomplete_step
    return redirect_to school_job_pay_package_path(@vacancy.id) unless step_valid?(PayPackageForm)
    return redirect_to school_job_supporting_documents_path(@vacancy.id) unless step_valid?(SupportingDocumentsForm)
    return redirect_to school_job_application_details_path(@vacancy.id) unless step_valid?(ApplicationDetailsForm)
    return redirect_to school_job_job_summary_path(@vacancy.id) unless step_valid?(JobSummaryForm)
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
