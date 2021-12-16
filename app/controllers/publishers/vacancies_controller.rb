class Publishers::VacanciesController < Publishers::Vacancies::BaseController
  before_action :redirect_if_published, only: %i[preview review]
  before_action :invent_job_alert_search_criteria, only: %i[show preview]
  before_action :redirect_to_new_features_reminder, only: %i[create]

  def show
    form_sequence.validate_all_steps
    session[:current_step] = :review
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def create_or_copy; end

  def select_a_job_for_copying; end

  def redirect_to_copy_job
    redirect_to new_organisation_job_copy_path(job_id: params[:job_id])
  end

  def create
    redirect_to select_a_job_for_copying_organisation_jobs_path and return if params[:create_or_copy] == "copy-existing"

    reset_session_vacancy!
    vacancy = Vacancy.create(organisations: [current_organisation])
    vacancy.update(enable_job_applications: false) if current_organisation.local_authority?
    redirect_to organisation_job_build_path(vacancy.id, :job_role)
  end

  def review
    reset_session_vacancy!
    session[:current_step] = :review
    vacancy.update(completed_steps: completed_steps) if all_steps_valid?
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def destroy
    vacancy.supporting_documents.purge_later
    vacancy.trashed!
    remove_google_index(vacancy)
    redirect_to organisation_path, success: t(".success_html", job_title: vacancy.job_title)
  end

  def preview
    redirect_to back_to(show_errors: true) unless all_steps_valid?

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def summary
    return redirect_to organisation_job_review_path(vacancy.id) unless vacancy.published?

    @vacancy = VacancyPresenter.new(vacancy)
    @feedback_form = Publishers::JobListing::FeedbackForm.new
  end

  private

  def invent_job_alert_search_criteria
    @invented_job_alert_search_criteria = Search::CriteriaInventor.new(vacancy).criteria
  end

  def redirect_if_published
    return unless vacancy.published?

    redirect_to organisation_job_path(vacancy.id), notice: t("messages.jobs.already_published")
  end

  def redirect_to_new_features_reminder
    redirect_to reminder_new_features_path if show_feature_reminder_page?
  end

  def show_feature_reminder_page?
    return false if session[:visited_application_feature_reminder_page] || session[:visited_new_features_page]

    Vacancy.published.where(
      publisher_id: current_publisher.id,
      enable_job_applications: false,
      created_at: Publishers::NewFeaturesController::NEW_FEATURES_PAGE_UPDATED_AT..).any?
  end
end
