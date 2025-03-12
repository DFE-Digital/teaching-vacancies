class Publishers::VacanciesController < Publishers::Vacancies::BaseController
  before_action :invent_job_alert_search_criteria, only: %i[show preview]
  before_action :redirect_to_new_features_reminder, only: %i[create]

  before_action :show_publisher_preferences, only: %i[index]
  before_action :redirect_to_show_publisher_profile_incomplete, only: %i[index], if: -> { signing_in? }, unless: -> { current_organisation.profile_complete? }

  helper_method :vacancy_statistics_form

  def show
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def index
    @selected_type = params[:type] || :published
    @publisher_preference = PublisherPreference.find_or_create_by(publisher: current_publisher, organisation: current_organisation)
    @sort = Publishers::VacancySort.new(current_organisation, @selected_type).update(sort_by: params[:sort_by])
  end

  # We don't save anything here - just redirect to the show page
  def save_and_finish_later
    redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success")
  end

  def create
    vacancy = Vacancy.create!(publisher: current_publisher, publisher_organisation: current_organisation, organisations: [current_organisation])

    if current_organisation.school?
      vacancy.update(organisations: [current_organisation])
      vacancy.update(phases: [current_organisation.readable_phase]) if current_organisation.readable_phase
    end

    redirect_to organisation_job_build_path(vacancy.id, :job_location)
  end

  def review
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def destroy
    vacancy.supporting_documents.purge_later
    vacancy.update_attribute(:status, :trashed)
    remove_google_index(vacancy)
    redirect_to organisation_jobs_with_type_path, success: t(".success_html", job_title: vacancy.job_title)
  end

  def preview
    redirect_to organisation_job_path(vacancy.id) unless all_steps_valid?

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def convert_to_draft
    vacancy.draft!
    redirect_to organisation_job_path(vacancy.id)
  end

  def summary
    return redirect_to organisation_job_path(vacancy.id) unless vacancy.published?

    @vacancy = VacancyPresenter.new(vacancy)
    @feedback_form = Publishers::JobListing::FeedbackForm.new
  end

  def download_equal_opps_pdf
    equal_opps_report = EqualOpportunitiesReport.find_by(vacancy_id: vacancy.id)
    pdf = EqualOppsPdfGenerator.new(vacancy, equal_opps_report).generate

    send_data(
      pdf.render,
      filename: "equal_opps_report_for_#{vacancy.id}.pdf",
      type: "application/pdf",
      disposition: "inline",
    )
  end

  private

  def invent_job_alert_search_criteria
    @invented_job_alert_search_criteria = Search::CriteriaInventor.new(vacancy).criteria
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

  def show_publisher_preferences
    return unless current_organisation.local_authority?
    return if PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)

    redirect_to new_publishers_publisher_preference_path
  end

  def vacancy_statistics_form(vacancy)
    if vacancy.id == params[:invalid_form_job_id]
      # Trigger validations to add errors to form
      Publishers::VacancyStatisticsForm.new(statistics_params).tap(&:valid?)
    else
      @vacancy_statistics_form ||= Publishers::VacancyStatisticsForm.new
    end
  end

  def statistics_params
    params.require(:publishers_vacancy_statistics_form).permit(:listed_elsewhere, :hired_status)
  end

  def signing_in?
    params[:signing_in].present?
  end

  def redirect_to_show_publisher_profile_incomplete
    redirect_to publishers_organisation_profile_incomplete_path(current_organisation)
  end
end
