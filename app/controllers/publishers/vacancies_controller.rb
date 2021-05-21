class Publishers::VacanciesController < Publishers::Vacancies::BaseController
  include Publishers::Wizardable

  before_action :set_vacancy, only: %i[destroy edit preview review show summary]
  before_action :redirect_if_published, only: %i[preview review]
  before_action :devise_job_alert_search_criteria, only: %i[show preview]

  def show
    return redirect_to organisation_job_review_path(@vacancy.id), notice: t(".notice") unless @vacancy.published?

    @vacancy = VacancyPresenter.new(@vacancy)
  end

  def create
    reset_session_vacancy!
    vacancy = Vacancy.create(organisation_vacancies_attributes: [{ organisation: current_organisation }])
    redirect_to organisation_job_build_path(vacancy.id, :job_location)
  end

  def edit
    return redirect_to organisation_job_review_path(@vacancy.id) unless @vacancy.published?

    validate_all_steps
    session[:current_step] = :review
    @vacancy = VacancyPresenter.new(@vacancy)
  end

  def review
    reset_session_vacancy!

    if all_steps_valid?
      session[:current_step] = :review
      set_completed_step
      validate_all_steps
    else
      session[:current_step] = :edit_incomplete
      redirect_to_incomplete_step
    end

    @vacancy = VacancyPresenter.new(@vacancy)
  end

  def destroy
    @vacancy.delete_documents
    @vacancy.trashed!
    remove_google_index(@vacancy)
    redirect_to organisation_path, success: t(".success_html", job_title: @vacancy.job_title)
  end

  def preview
    @vacancy = VacancyPresenter.new(@vacancy)
  end

  def summary
    return redirect_to organisation_job_review_path(@vacancy.id) unless @vacancy.published?

    @vacancy = VacancyPresenter.new(@vacancy)
    @feedback_form = Publishers::JobListing::FeedbackForm.new
  end

  private

  def devise_job_alert_search_criteria
    @devised_job_alert_search_criteria = Search::CriteriaDeviser.new(@vacancy).criteria
  end

  def redirect_if_published
    return unless @vacancy.published?

    redirect_to organisation_job_path(@vacancy.id), notice: t("messages.jobs.already_published")
  end

  def redirect_to_incomplete_step
    return redirect_to organisation_job_build_path(@vacancy.id, :job_details) unless step_valid?(Publishers::JobListing::JobDetailsForm)
    return redirect_to organisation_job_build_path(@vacancy.id, :pay_package) unless step_valid?(Publishers::JobListing::PayPackageForm)
    return redirect_to organisation_job_build_path(@vacancy.id, :important_dates) unless step_valid?(Publishers::JobListing::ImportantDatesForm)
    return redirect_to organisation_job_build_path(@vacancy.id, :documents) unless @vacancy.completed_step >= steps_config[:documents][:number]
    return redirect_to organisation_job_build_path(@vacancy.id, :applying_for_the_job) unless step_valid?(Publishers::JobListing::ApplyingForTheJobForm)
    return redirect_to organisation_job_build_path(@vacancy.id, :job_summary) unless step_valid?(Publishers::JobListing::JobSummaryForm)
  end

  def set_completed_step
    @vacancy.update(completed_step: process_steps.current_step_number)
  end

  def validate_all_steps
    step_valid?(Publishers::JobListing::JobDetailsForm)
    step_valid?(Publishers::JobListing::PayPackageForm)
    step_valid?(Publishers::JobListing::ImportantDatesForm)
    step_valid?(Publishers::JobListing::ApplyingForTheJobForm)
    step_valid?(Publishers::JobListing::JobSummaryForm)
  end
end
