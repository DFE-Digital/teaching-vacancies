class HiringStaff::VacanciesController < HiringStaff::Vacancies::ApplicationController
  before_action :set_vacancy, only: %i[destroy edit preview review show summary]
  before_action :redirect_if_published, only: %i[preview review]
  before_action :redirect_unless_permitted, only: %i[preview summary]
  before_action :devise_job_alert_search_criteria, only: %i[show preview]

  def show
    unless @vacancy.published?
      return redirect_to organisation_job_review_path(@vacancy.id),
                         notice: I18n.t("messages.jobs.view.only_published")
    end
    @vacancy = VacancyPresenter.new(@vacancy)
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
    return redirect_to organisation_job_review_path(@vacancy.id) unless @vacancy.published?

    @vacancy.update(state: "edit_published")
    @vacancy = VacancyPresenter.new(@vacancy)
  end

  def review
    reset_session_vacancy!
    store_vacancy_attributes(@vacancy.attributes)

    if @vacancy.valid? || %w[copy edit_published].include?(@vacancy.state)
      update_vacancy_state
      set_completed_step
    else
      redirect_to_incomplete_step
    end

    session[:current_step] = :review
    @vacancy = VacancyPresenter.new(@vacancy)
    @vacancy.valid? if params[:source]&.eql?("publish")
  end

  def destroy
    @vacancy.delete_documents
    @vacancy.trash!
    remove_google_index(@vacancy)
    Auditor::Audit.new(@vacancy, "vacancy.delete", current_session_id).log
    redirect_to organisation_path, success: I18n.t("messages.jobs.delete_html", job_title: @vacancy.job_title)
  end

  def preview
    @vacancy = VacancyPresenter.new(@vacancy)
  end

  def summary
    @vacancy = VacancyPresenter.new(@vacancy)
  end

private

  def step_valid?(step_form)
    validation = step_form.new(@vacancy.attributes)
    validation&.valid?.tap { |valid| clear_cache_and_step unless valid }
  end

  def redirect_if_published
    if @vacancy.published?
      redirect_to organisation_job_path(@vacancy.id),
                  notice: I18n.t("messages.jobs.already_published")
    end
  end

  def redirect_unless_permitted
    if @vacancy.state == "copy" && !@vacancy.valid?
      redirect_to organisation_job_review_path(@vacancy.id)
    elsif @vacancy.state == "edit_published" && !@vacancy.valid?
      redirect_to edit_organisation_job_path(@vacancy.id)
    elsif !@vacancy.valid?
      redirect_to_incomplete_step
    end
  end

  def redirect_to_incomplete_step
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
    session[:current_step] = ""
  end

  def set_completed_step
    @vacancy.update(completed_step: current_step)
  end

  def update_vacancy_state
    state = if params[:edit_draft] == "true" || @vacancy&.state == "edit"
      "edit"
            elsif @vacancy&.state == "copy"
      "copy"
            else
      "review"
            end
    @vacancy.update(state: state)
  end

  def devise_job_alert_search_criteria
    @devised_job_alert_search_criteria = Search::CriteriaDeviser.new(@vacancy).criteria
  end
end
