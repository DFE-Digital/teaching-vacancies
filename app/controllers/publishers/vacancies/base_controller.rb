require "indexing"

class Publishers::Vacancies::BaseController < Publishers::BaseController
  include Publishers::Wizardable

  private

  helper_method :current_step, :step_process, :vacancy, :vacancies, :all_steps_valid?, :next_invalid_step

  def step_process
    Publishers::Vacancies::VacancyStepProcess.new(
      current_step || :review,
      vacancy: vacancy,
      organisation: current_organisation,
    )
  end

  def vacancies
    @vacancies ||= current_organisation.all_vacancies
  end

  def vacancy
    # Scope to internal vacancies to disallow editing of external ones

    # As the vacancy is not associated with an organisation upon creation, calling the vacancies method will return an empty array as an organisation is not associated
    # with it. To fix this, before the vacancy's status is set (and therefore before an organisation is associated), we find the job from the vacancies where status is nil.
    @vacancy ||= (vacancies.internal.find_by(id: params[:job_id].presence || params[:id]) || Vacancy.where(status: nil).find(params[:job_id].presence || params[:id]))
  end

  def form_sequence
    @form_sequence ||= Publishers::VacancyFormSequence.new(
      vacancy: vacancy,
      organisation: current_organisation,
    )
  end

  def all_steps_valid?
    form_sequence.all_steps_valid?
  end

  def redirect_to_next_step
    if all_steps_valid? || save_and_finish_later?
      if vacancy.draft? && all_steps_valid?
        redirect_to organisation_job_review_path(vacancy.id)
      else
        redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success")
      end
    else
      redirect_to organisation_job_build_path(vacancy.id, next_invalid_step)
    end
  end

  def next_invalid_step
    # Due to subjects being an optional step (no validations) it needs to be handled differently
    return :subjects if next_incomplete_step_subjects?

    form_sequence.validate_all_steps.filter_map { |step, form| step unless form.valid? }.first
  end

  def remove_google_index(job)
    return if DisableExpensiveJobs.enabled?

    url = job_url(job)
    RemoveGoogleIndexQueueJob.perform_later(url)
  end

  def update_google_index(job)
    return if DisableExpensiveJobs.enabled?

    url = job_url(job)
    UpdateGoogleIndexQueueJob.perform_later(url)
  end

  def next_incomplete_step_subjects?
    return unless vacancy.completed_steps.exclude?("subjects")

    vacancy.completed_steps.last == if vacancy.allow_key_stages?
                                      "key_stages"
                                    else
                                      "job_title"
                                    end
  end

  def save_and_finish_later?
    params["save_and_finish_later"] == "true"
  end
end
