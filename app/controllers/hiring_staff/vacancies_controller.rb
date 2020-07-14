class HiringStaff::VacanciesController < HiringStaff::Vacancies::ApplicationController
  before_action :set_vacancy, only: %i[review preview]

  def show
    vacancy = find_active_vacancy_by_id
    unless vacancy.published?
      return redirect_to organisation_job_review_path(vacancy.id),
                         notice: I18n.t('messages.jobs.view.only_published')
    end
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def new
    reset_session_vacancy!
    if current_organisation.is_a?(SchoolGroup)
      redirect_to job_location_organisation_job_path
    elsif current_organisation.is_a?(School)
      redirect_to job_specification_organisation_job_path
    end
  end

  def edit
    vacancy = current_organisation.vacancies.find(id)
    return redirect_to organisation_job_review_path(vacancy.id) unless vacancy.published?

    vacancy.update(state: 'edit_published') unless vacancy&.state == 'edit_published'
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def review
    return redirect_to organisation_job_path(@vacancy.id),
                       notice: I18n.t('messages.jobs.already_published') if @vacancy.published?

    reset_session_vacancy!
    store_vacancy_attributes(@vacancy.attributes)


    unless @vacancy.valid?
      redirect_to_incomplete_step
    else

      update_vacancy_state
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

    redirect_to organisation_path, success: I18n.t('messages.jobs.delete_html', job_title: @vacancy.job_title)
  end

  def preview
    return redirect_to organisation_job_path(@vacancy.id),
                       notice: I18n.t('messages.jobs.already_published') if @vacancy.published?
    redirect_to_incomplete_step unless @vacancy.valid?
    @vacancy = VacancyPresenter.new(@vacancy)
  end

  def summary
    vacancy = current_organisation.vacancies.published.find(vacancy_id)
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
    (validation&.valid?).tap { |valid| clear_cache_and_step unless valid }
  end

  def redirect_to_incomplete_step
    if !step_valid?(SchoolForm) && @vacancy.job_location == 'at_one_school' && current_organisation.is_a?(SchoolGroup)
      return redirect_to organisation_job_school_path(@vacancy.id)
    end
    return redirect_to organisation_job_job_specification_path(@vacancy.id) unless step_valid?(JobSpecificationForm)
    return redirect_to organisation_job_pay_package_path(@vacancy.id) unless step_valid?(PayPackageForm)
    return redirect_to organisation_job_important_dates_path(@vacancy.id) unless step_valid?(ImportantDatesForm)
    return redirect_to organisation_job_supporting_documents_path(@vacancy.id) unless
      step_valid?(SupportingDocumentsForm)
    return redirect_to organisation_job_application_details_path(@vacancy.id) unless step_valid?(ApplicationDetailsForm)
    return redirect_to organisation_job_job_summary_path(@vacancy.id) unless step_valid?(JobSummaryForm)
  end

  def clear_cache_and_step
    flash.clear
    session[:current_step] = ''
  end

  def set_completed_step
    @vacancy.update(completed_step: current_step)
  end

  def find_active_vacancy_by_id
    current_organisation.vacancies.active.find(id)
  end

  def update_vacancy_state
    if params[:edit_draft] == 'true'
      state = 'edit'
    elsif @vacancy&.state == 'copy'
      state = 'copy'
    else
      state = 'review'
    end
    @vacancy.update(state: state)
  end
end
