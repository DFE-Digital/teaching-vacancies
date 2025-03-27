require "google_indexing"

class Publishers::Vacancies::BaseController < Publishers::BaseController
  include Publishers::Wizardable

  delegate :all_steps_valid?, :next_invalid_step, to: :form_sequence

  private

  helper_method :current_step, :step_process, :vacancy, :vacancies, :all_steps_valid?, :next_invalid_step, :back_path

  def step_process
    @step_process ||= if action_name == "update"
                        Publishers::Vacancies::VacancyStepProcess.new(
                          current_step || :review,
                          vacancy: vacancy,
                          organisation: current_organisation,
                          step_params: params,
                        )
                      else
                        Publishers::Vacancies::VacancyStepProcess.new(
                          current_step || :review,
                          vacancy: vacancy,
                          organisation: current_organisation,
                        )
                      end
  end

  def vacancies
    @vacancies ||= current_organisation.all_vacancies
  end

  def vacancy
    # Scope to internal vacancies to disallow editing of external ones

    # As the vacancy is not associated with an organisation upon creation, calling the vacancies method will return an empty array as an organisation is not associated
    # with it. To fix this, before the vacancy's status is set (and therefore before an organisation is associated), we find the job from the vacancies where status is nil.
    @vacancy ||= vacancies.internal.find_by(id: params[:job_id].presence || params[:id]) || Vacancy.where(status: nil).find(params[:job_id].presence || params[:id])
  end

  def form_sequence
    @form_sequence ||= Publishers::VacancyFormSequence.new(
      vacancy: vacancy,
      organisation: current_organisation,
      step_process: step_process,
    )
  end

  def redirect_to_next_step
    if save_and_finish_later?
      redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success")
    elsif all_steps_valid?
      if vacancy.published?
        redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success")
      else
        redirect_to organisation_job_review_path(vacancy.id)
      end
    else
      redirect_to organisation_job_build_path(vacancy.id, next_invalid_step)
    end
  end

  def back_path
    if params[:back_to_review] == "true"
      organisation_job_review_path(vacancy.id)
    elsif params[:back_to_show] == "true"
      organisation_job_path(vacancy.id)
    elsif step_process.previous_step
      organisation_job_build_path(vacancy.id, step_process.previous_step)
    else
      organisation_jobs_with_type_path(:published)
    end
  end

  def update_google_index(job)
    return if DisableExpensiveJobs.enabled?

    url = job_url(job)
    UpdateGoogleIndexQueueJob.perform_later(url)
  end

  def save_and_finish_later?
    params["save_and_finish_later"] == "true"
  end
end
