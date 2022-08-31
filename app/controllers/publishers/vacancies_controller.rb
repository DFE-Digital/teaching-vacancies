class Publishers::VacanciesController < Publishers::Vacancies::BaseController
  before_action :redirect_if_published, only: %i[preview review]
  before_action :invent_job_alert_search_criteria, only: %i[show preview]
  before_action :redirect_to_new_features_reminder, only: %i[create]

  def show
    form_sequence.validate_all_steps
    session[:current_step] = :review
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def create
    reset_session_vacancy!

    vacancy = Vacancy.create
    if current_organisation.school?
      vacancy.update(organisations: [current_organisation])
      vacancy.update(phases: [current_organisation.readable_phase]) if current_organisation.readable_phase
    elsif current_organisation.local_authority?
      vacancy.update(enable_job_applications: false)
    end
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
    redirect_to reminder_publishers_new_features_path if show_application_feature_reminder_page?
  end

  def show_application_feature_reminder_page?
    return false if session[:visited_application_feature_reminder_page] || session[:visited_new_features_page]

    Vacancy.published.where(
      publisher_id: current_publisher.id,
      enable_job_applications: true,
      created_at: Publishers::NewFeaturesController::NEW_FEATURES_PAGE_UPDATED_AT..,
    ).none?
  end
end
