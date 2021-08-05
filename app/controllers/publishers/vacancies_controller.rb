class Publishers::VacanciesController < Publishers::Vacancies::BaseController
  include Publishers::Wizardable

  before_action :redirect_if_published, only: %i[preview review]
  before_action :devise_job_alert_search_criteria, only: %i[show preview]

  helper_method :applying_for_the_job_fields, :important_dates_fields, :job_details_fields, :job_location_fields, :job_summary_fields, :pay_package_fields, :schools_fields

  def show
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def create
    reset_session_vacancy!
    vacancy = Vacancy.create(organisation_vacancies_attributes: [{ organisation: current_organisation }])
    redirect_to organisation_job_build_path(vacancy.id, :job_location)
  end

  def edit
    return redirect_to organisation_job_review_path(vacancy.id) unless vacancy.published?

    validate_all_steps
    session[:current_step] = :review
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def review
    reset_session_vacancy!

    if all_steps_valid?
      session[:current_step] = :review
      vacancy.update(completed_step: current_step_number, completed_steps: completed_steps)
    else
      session[:current_step] = :edit_incomplete
      redirect_to_incomplete_step
    end

    @vacancy = VacancyPresenter.new(vacancy)
  end

  def destroy
    vacancy.supporting_documents.purge_later
    vacancy.trashed!
    remove_google_index(vacancy)
    redirect_to organisation_path, success: t(".success_html", job_title: vacancy.job_title)
  end

  def preview
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def summary
    return redirect_to organisation_job_review_path(vacancy.id) unless vacancy.published?

    @vacancy = VacancyPresenter.new(vacancy)
    @feedback_form = Publishers::JobListing::FeedbackForm.new
  end

  private

  def devise_job_alert_search_criteria
    @devised_job_alert_search_criteria = Search::CriteriaDeviser.new(vacancy).criteria
  end

  def redirect_if_published
    return unless vacancy.published?

    redirect_to organisation_job_path(vacancy.id), notice: t("messages.jobs.already_published")
  end

  def redirect_to_incomplete_step
    return redirect_to organisation_job_build_path(vacancy.id, :job_details) unless step_valid?(:job_details)
    return redirect_to organisation_job_build_path(vacancy.id, :pay_package) unless step_valid?(:pay_package)
    return redirect_to organisation_job_build_path(vacancy.id, :important_dates) unless step_valid?(:important_dates)
    return redirect_to organisation_job_build_path(vacancy.id, :documents) unless vacancy.completed_step >= steps_config[:documents][:number]
    return redirect_to organisation_job_build_path(vacancy.id, :applying_for_the_job) unless step_valid?(:applying_for_the_job)
    return redirect_to organisation_job_build_path(vacancy.id, :job_summary) unless step_valid?(:job_summary)
  end

  def validate_all_steps
    steps_config.except(:job_location, :schools, :supporting_documents, :documents, :review).each_key do |step|
      step_valid?(step)
    end
  end
end
