require "indexing"

class Publishers::Vacancies::BaseController < Publishers::BaseController
  include Publishers::Wizardable

  helper_method :current_step_number, :step_current, :steps_adjust, :steps_config, :vacancy

  def steps_adjust
    # Only adjust *after* job role step as the extra step for school groups comes after that
    return 0 if defined?(step) && step.in?(%i[job_role job_role_details])

    current_organisation.school_group? ? 0 : 1
  end

  def step_current
    return :review unless defined?(step)

    case step
    when :schools
      :job_location
    when :job_role_details
      :job_role
    else
      step
    end
  end

  def current_step_number
    steps_config[step_current][:number] - steps_adjust
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies.find(params[:job_id].presence || params[:id])
  end

  def all_steps_valid?
    steps_to_skip = if current_organisation.is_a?(School)
                      []
                    else
                      vacancy.job_location == "at_central_office" ? [:job_location] : %i[job_location schools]
                    end
    steps_to_skip.push(:documents, :review)
    steps_config.except(*steps_to_skip).keys.all? { |step| step_valid?(step) }
  end

  def step_valid?(step)
    step_form = "publishers/job_listing/#{step}_form".camelize.constantize

    # We need to merge in the current organisation otherwise the form will always be invalid for local authority users
    form = step_form.new(vacancy.slice(*send("#{step}_fields")).merge(current_organisation: current_organisation), vacancy)

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

  def update_google_index(job)
    return if DisableExpensiveJobs.enabled?

    url = job_url(job)
    UpdateGoogleIndexQueueJob.perform_later(url)
  end
end
