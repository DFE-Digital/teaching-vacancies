require "indexing"

class Publishers::Vacancies::BaseController < Publishers::BaseController
  include Publishers::Wizardable

  private

  helper_method :current_step, :step_process, :vacancy

  def step_process
    ::Publishers::Vacancies::VacancyStepProcess.new(
      current_step || :review,
      vacancy: vacancy,
      organisation: current_organisation,
      session: session,
    )
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies.find(params[:job_id].presence || params[:id])
  end

  def all_steps_valid?
    step_process.all_steps_valid?
  end

  def back_to(**extras)
    case params[:back_to]
    when "review"
      organisation_job_review_path(
        job_id: vacancy.id,
        anchor: "errors",
        **extras,
      )
    else
      organisation_job_path(
        id: vacancy.id,
        anchor: "errors",
        **extras,
      )
    end
  end

  def readable_job_location(job_location, school_name: nil, schools_count: nil)
    case job_location
    when "at_one_school"
      school_name
    when "at_multiple_schools"
      t("publishers.organisations.readable_job_location.at_multiple_schools_with_count", count: schools_count)
    when "central_office"
      t("publishers.organisations.readable_job_location.central_office")
    end
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
                                                          helpers.back_to_manage_jobs_link(vacancy),
                                                          class: "govuk-link--no-visited-state"))
  end

  def remove_google_index(job)
    return if DisableExpensiveJobs.enabled?

    url = job_url(job)
    RemoveGoogleIndexQueueJob.perform_later(url)
  end

  def reset_session_vacancy!
    session[:job_location] = nil
    session[:current_step] = nil
  end

  def update_google_index(job)
    return if DisableExpensiveJobs.enabled?

    url = job_url(job)
    UpdateGoogleIndexQueueJob.perform_later(url)
  end
end
