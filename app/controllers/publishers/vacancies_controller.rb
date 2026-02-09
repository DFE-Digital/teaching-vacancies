class Publishers::VacanciesController < Publishers::Vacancies::WizardBaseController
  before_action :invent_job_alert_search_criteria, only: %i[show preview]
  before_action :redirect_to_new_features_reminder, only: %i[create]

  before_action :set_publisher_preference, only: %i[index]
  before_action :strip_empty_checkbox_params, only: %i[index]
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

  # rubocop:disable Metrics/AbcSize
  def index
    @selected_type = (params[:type] || :live).to_sym
    @sort = Publishers::VacancySort.new(current_organisation, @selected_type).update(sort_by: params[:sort_by])
    scope = if @selected_type == :draft
              DraftVacancy.kept.where.not(job_title: nil)
            else
              PublishedVacancy.kept.public_send(VACANCY_TYPES.fetch(@selected_type))
            end

    accessible_org_ids = current_publisher.accessible_organisations(current_organisation).map(&:id)

    # Apply organisation filter from URL params if present, otherwise show all accessible
    @selected_organisation_ids = params[:organisation_ids]&.reject(&:blank?) || []
    org_ids_to_filter = @selected_organisation_ids.any? ? @selected_organisation_ids : accessible_org_ids

    vacancies = scope
                  .in_organisation_ids(org_ids_to_filter)
                  .order(@sort.by => @sort.order)

    @pagy, @vacancies = pagy(vacancies)
    @count = vacancies.count

    @vacancy_types = VACANCY_TYPES.keys
    @filter_form = Publishers::VacancyFilterForm.new(organisation_ids: @selected_organisation_ids)
  end
  # rubocop:enable Metrics/AbcSize

  # We don't save anything here - just redirect to the show page
  def save_and_finish_later
    redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success")
  end

  def create
    # anonymise_applications defaults to false for past applications, so we have to explicitly set nil here
    vacancy = DraftVacancy.create!(publisher: current_publisher, anonymise_applications: nil,
                                   publisher_organisation: current_organisation, organisations: [current_organisation])

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

  def set_publisher_preference
    if current_organisation.local_authority? # Local Authorities publisher need to set their preference for the local authority
      @publisher_preference = PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)
      redirect_to new_publishers_publisher_preference_path if @publisher_preference.nil?
    else # Other orgs (MATs and Schools) get default publisher preferences.
      @publisher_preference = PublisherPreference.find_or_create_by(publisher: current_publisher, organisation: current_organisation)
    end
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
    params.expect(publishers_vacancy_statistics_form: %i[listed_elsewhere hired_status])
  end

  def signing_in?
    params[:signing_in].present?
  end

  def redirect_to_show_publisher_profile_incomplete
    redirect_to publishers_organisation_profile_incomplete_path(current_organisation)
  end

  def strip_empty_checkbox_params
    params[:organisation_ids]&.reject!(&:blank?)
  end
end
