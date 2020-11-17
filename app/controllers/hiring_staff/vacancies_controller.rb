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

  def create
    vacancy = Vacancy.create(organisation_vacancies_attributes: [{ organisation: current_organisation }])
    redirect_to organisation_job_build_path(vacancy.id, :job_location)
  end

  def edit
    return redirect_to organisation_job_review_path(@vacancy.id) unless @vacancy.published?

    @vacancy.update(state: "edit_published")
    validate_all_steps
    @vacancy = VacancyPresenter.new(@vacancy)
  end

  def review
    if all_steps_valid? || %w[copy edit_published].include?(@vacancy.state)
      update_vacancy_state
      set_completed_step
      validate_all_steps
    else
      redirect_to_incomplete_step
    end

    session[:current_step] = :review
    @vacancy = VacancyPresenter.new(@vacancy)
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

  def devise_job_alert_search_criteria
    @devised_job_alert_search_criteria = Search::CriteriaDeviser.new(@vacancy).criteria
  end

  def redirect_if_published
    if @vacancy.published?
      redirect_to organisation_job_path(@vacancy.id),
                  notice: I18n.t("messages.jobs.already_published")
    end
  end

  def redirect_to_incomplete_step
    return redirect_to organisation_job_build_path(@vacancy.id, :job_details) unless step_valid?(JobDetailsForm)
    return redirect_to organisation_job_build_path(@vacancy.id, :pay_package) unless step_valid?(PayPackageForm)
    return redirect_to organisation_job_build_path(@vacancy.id, :important_dates) unless step_valid?(ImportantDatesForm)
    return redirect_to organisation_job_build_path(@vacancy.id, :supporting_documents) unless step_valid?(SupportingDocumentsForm)
    return redirect_to organisation_job_build_path(@vacancy.id, :applying_for_the_job) unless step_valid?(ApplyingForTheJobForm)
    return redirect_to organisation_job_build_path(@vacancy.id, :job_summary) unless step_valid?(JobSummaryForm)
  end

  def redirect_unless_permitted
    if @vacancy.state == "copy" && !all_steps_valid?
      redirect_to organisation_job_review_path(@vacancy.id)
    elsif @vacancy.state == "edit_published" && !all_steps_valid?
      redirect_to edit_organisation_job_path(@vacancy.id)
    elsif !all_steps_valid?
      redirect_to_incomplete_step
    end
  end

  def set_completed_step
    @vacancy.update(completed_step: current_step_number)
  end

  def update_vacancy_state
    state = if params[:edit_draft] == "true" || @vacancy.state == "edit"
              "edit"
            elsif @vacancy.state == "copy"
              "copy"
            else
              "review"
            end
    @vacancy.update(state: state)
  end

  def validate_all_steps
    step_valid?(JobDetailsForm)
    step_valid?(PayPackageForm)
    step_valid?(ImportantDatesForm)
    step_valid?(SupportingDocumentsForm)
    step_valid?(ApplyingForTheJobForm)
    step_valid?(JobSummaryForm)
  end
end
