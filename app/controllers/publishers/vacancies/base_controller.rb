require "indexing"

class Publishers::Vacancies::BaseController < Publishers::BaseController
  include Publishers::Wizardable

  private

  helper_method :current_step, :step_process, :vacancy, :vacancies

  def step_process
    Publishers::Vacancies::VacancyStepProcess.new(
      current_step || :review,
      vacancy: vacancy,
      organisation: current_organisation,
      session: session,
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

  def back_to(**extras)
    organisation_job_path(
      id: vacancy.id,
      anchor: "errors",
      **extras,
    )
  end

  def redirect_updated_job_with_message
    updated_job_path = if vacancy.published? || params[:back_to] == "manage_draft"
                         organisation_job_path(vacancy.id)
                       else
                         organisation_job_review_path(vacancy.id)
                       end

    redirect_to updated_job_path,
                success: t("messages.jobs.listing_updated_html",
                           job_title: vacancy.job_title,
                           link_to: helpers.govuk_link_to(t("messages.jobs.listing_updated_link_text"),
                                                          jobs_with_type_organisation_path(vacancy.publication_status),
                                                          class: "govuk-link--no-visited-state"))
  end

  def remove_google_index(job)
    return if DisableExpensiveJobs.enabled?

    url = job_url(job)
    RemoveGoogleIndexQueueJob.perform_later(url)
  end

  def reset_session_vacancy!
    session[:current_step] = nil
  end

  def update_google_index(job)
    return if DisableExpensiveJobs.enabled?

    url = job_url(job)
    UpdateGoogleIndexQueueJob.perform_later(url)
  end
end
