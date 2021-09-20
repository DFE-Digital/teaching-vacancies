class Publishers::VacanciesController < Publishers::Vacancies::BaseController
  before_action :redirect_if_published, only: %i[preview review]
  before_action :invent_job_alert_search_criteria, only: %i[show preview]

  def show
    redirect_to organisation_job_review_path(vacancy.id) unless vacancy.published?

    validate_all_steps
    session[:current_step] = :review
    @vacancy = VacancyPresenter.new(vacancy)
  end

  def create
    reset_session_vacancy!
    vacancy = Vacancy.create(organisation_vacancies_attributes: [{ organisation: current_organisation }])
    redirect_to organisation_job_build_path(vacancy.id, :job_role)
  end

  def review
    reset_session_vacancy!

    if all_steps_valid?
      session[:current_step] = :review
      vacancy.update(completed_steps: completed_steps)
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

  def invent_job_alert_search_criteria
    @invented_job_alert_search_criteria = Search::CriteriaInventor.new(vacancy).criteria
  end

  def redirect_if_published
    return unless vacancy.published?

    redirect_to organisation_job_path(vacancy.id), notice: t("messages.jobs.already_published")
  end

  def redirect_to_incomplete_step
    step_process.steps.excluding(:review).each do |step|
      if step == :documents
        return redirect_to organisation_job_build_path(vacancy.id, :documents) unless vacancy.completed_steps.include?("documents")
      else
        return redirect_to organisation_job_build_path(vacancy.id, step) unless step_valid?(step)
      end
    end
  end

  def validate_all_steps
    step_process.validatable_steps.each do |step|
      step_valid?(step)
    end
  end
end
