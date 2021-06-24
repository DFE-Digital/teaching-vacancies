require "indexing"

class Publishers::Vacancies::BaseController < Publishers::BaseController
  include Publishers::Wizardable

  helper_method :current_step_number, :step_current, :steps_adjust, :steps_config, :vacancy

  def steps_adjust
    current_organisation.school_group? ? 0 : 1
  end

  def step_current
    if defined?(step)
      step == :schools ? :job_location : step
    else
      :review
    end
  end

  def current_step_number
    steps_config[step_current][:number] - steps_adjust
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies.find(params[:job_id].presence || params[:id])
  end

  def all_steps_valid?
    all_invalid_steps.none?
  end

  def all_invalid_steps
    @all_invalid_steps ||= steps_config.except(:job_location, :schools, :supporting_documents, :review).map do |step|
      step unless step_valid?(step.first)
    end
  end

  def step_valid?(step)
    # We need to merge in the current organisation otherwise the form will always be invalid for local authority users
    form = "Publishers::JobListing::#{step.to_s.camelize}Form".constantize.new(
      vacancy.slice(*send("#{step}_fields"))
             .merge(current_organisation: current_organisation),
      vacancy,
    )

    form.valid?.tap do
      vacancy.errors.merge!(form.errors)
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

  def redirect_saved_draft_with_message
    redirect_to jobs_with_type_organisation_path("draft"), success: t("messages.jobs.draft_saved_html", job_title: vacancy.job_title)
  end

  def redirect_updated_job_with_message
    updated_job_path = vacancy.published? ? edit_organisation_job_path(vacancy.id) : organisation_job_review_path(vacancy.id)
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

  def review_path_with_errors(vacancy)
    organisation_job_review_path(job_id: vacancy.id, anchor: "errors", source: "publish")
  end

  def update_google_index(job)
    return if DisableExpensiveJobs.enabled?

    url = job_url(job)
    UpdateGoogleIndexQueueJob.perform_later(url)
  end
end
