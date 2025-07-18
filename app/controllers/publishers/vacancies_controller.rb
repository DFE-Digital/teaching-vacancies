class Publishers::VacanciesController < Publishers::Vacancies::BaseController
  before_action :invent_job_alert_search_criteria, only: %i[show preview]
  before_action :redirect_to_new_features_reminder, only: %i[create]

  before_action :show_publisher_preferences, only: %i[index]
  before_action :redirect_to_show_publisher_profile_incomplete, only: %i[index], if: -> { signing_in? }, unless: -> { current_organisation.profile_complete? }

  helper_method :vacancy_statistics_form

  def start; end

  def show
    @vacancy = VacancyPresenter.new(vacancy)
    @next_invalid_step = next_invalid_step
    @current_organisation = current_organisation
    @step_process = step_process
  end

  # This helps prevent parameters other than these specified arriving as a method on Vacancy
  VACANCY_TYPES =
    {
      live: :live,
      draft: :draft,
      pending: :pending,
      expired: :expired,
      awaiting_feedback: :awaiting_feedback_recently_expired,
    }.freeze

  def index
    @selected_type = (params[:type] || :live).to_sym
    @publisher_preference = PublisherPreference.find_or_create_by(publisher: current_publisher, organisation: current_organisation)
    @sort = Publishers::VacancySort.new(current_organisation, @selected_type).update(sort_by: params[:sort_by])

    scope = if @selected_type == :draft
              DraftVacancy.kept
            else
              PublishedVacancy.kept.public_send(VACANCY_TYPES.fetch(@selected_type))
            end
    vacancies = scope
                  .in_organisation_ids(current_publisher.accessible_organisations(current_organisation).map(&:id))
                  .order(@sort.by => @sort.order)
                  .where.not(job_title: nil)

    @pagy, @vacancies = pagy(vacancies)
    @count = vacancies.count

    @vacancy_types = VACANCY_TYPES.keys
  end

  # We don't save anything here - just redirect to the show page
  def save_and_finish_later
    redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success")
  end

  def create
    vacancy = DraftVacancy.create!(publisher: current_publisher, publisher_organisation: current_organisation, organisations: [current_organisation])

    if current_organisation.school? && current_organisation.phase.in?(Vacancy::SCHOOL_PHASES_MATCHING_VACANCY_PHASES)
      vacancy.update!(phases: [current_organisation.phase])
    end

    redirect_to organisation_job_build_path(vacancy.id, Wicked::FIRST_STEP)
  end

  def review
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def destroy
    vacancy.trash!
    redirect_to organisation_jobs_with_type_path, success: t(".success_html", job_title: vacancy.job_title)
  end

  def preview
    redirect_to organisation_job_path(vacancy.id) unless all_steps_valid?

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def convert_to_draft
    vacancy.update!(type: "DraftVacancy")
    redirect_to organisation_job_path(vacancy.id)
  end

  def summary
    return redirect_to organisation_job_path(vacancy.id) unless vacancy.published?

    @vacancy = VacancyPresenter.new(vacancy)
    @feedback_form = Publishers::JobListing::FeedbackForm.new
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

    PublishedVacancy.kept.where(
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
