module Publishers::Wizardable
  STRIP_CHECKBOXES = {
    job_role_details: %i[additional_job_roles],
    schools: %i[organisation_ids],
    job_details: %i[subjects working_patterns],
  }.freeze

  def steps_config
    {
      job_role: { number: 1, title: I18n.t("publishers.vacancies.steps.job_role") },
      job_role_details: { number: 1, title: I18n.t("publishers.vacancies.steps.job_role") },
      job_location: { number: 2, title: I18n.t("publishers.vacancies.steps.job_location") },
      schools: { number: 2, title: I18n.t("publishers.vacancies.steps.job_location") },
      job_details: { number: 3, title: I18n.t("publishers.vacancies.steps.job_details") },
      pay_package: { number: 4, title: I18n.t("publishers.vacancies.steps.pay_package") },
      important_dates: { number: 5, title: I18n.t("publishers.vacancies.steps.important_dates") },
      documents: { number: 6, title: I18n.t("publishers.vacancies.steps.documents") },
      applying_for_the_job: { number: 7, title: I18n.t("publishers.vacancies.steps.applying_for_the_job") },
      job_summary: { number: 8, title: I18n.t("publishers.vacancies.steps.job_summary") },
      review: { number: 9, title: I18n.t("publishers.vacancies.steps.review_heading") },
    }.freeze
  end

  def job_role_fields
    %i[primary_job_role]
  end

  def job_role_details_fields
    %i[additional_job_roles]
  end

  def job_location_fields
    %i[job_location]
  end

  def schools_fields
    %i[organisation_ids]
  end

  def job_details_fields
    %i[job_title contract_type contract_type_duration working_patterns subjects]
  end

  def pay_package_fields
    %i[actual_salary salary benefits]
  end

  def documents_fields
    []
  end

  def important_dates_fields
    %i[starts_asap starts_on publish_on expires_at]
  end

  def applying_for_the_job_fields
    %i[application_link enable_job_applications contact_email contact_number personal_statement_guidance school_visits how_to_apply]
  end

  def job_summary_fields
    %i[job_advert about_school]
  end

  def job_role_params(params)
    params.require(:publishers_job_listing_job_role_form)
          .permit(:primary_job_role).merge(completed_steps: completed_steps)
  end

  def job_role_details_params(params)
    params.require(:publishers_job_listing_job_role_details_form)
          .permit(:send_responsible, additional_job_roles: []).merge(completed_steps: completed_steps)
  end

  def job_location_params(params)
    job_location = params[:publishers_job_listing_job_location_form][:job_location]
    readable_job_location = readable_job_location(
      job_location, school_name: current_organisation.name, schools_count: vacancy.organisation_ids.count
    )
    attributes_to_merge = {
      completed_steps: completed_steps,
      readable_job_location: job_location == "central_office" ? readable_job_location : nil,
      organisation_ids: job_location == "central_office" ? current_organisation.id : nil,
    }
    session[:job_location] = job_location
    params.require(:publishers_job_listing_job_location_form).permit(:job_location).merge(attributes_to_merge.compact)
  end

  def schools_params(params)
    job_location = session[:job_location].presence || vacancy.job_location
    organisation_ids = params[:publishers_job_listing_schools_form][:organisation_ids]
    school_name = if organisation_ids.is_a?(String) && organisation_ids.present?
                    School.find(params[:publishers_job_listing_schools_form][:organisation_ids]).name
                  end
    schools_count = if organisation_ids.is_a?(Array)
                      params[:publishers_job_listing_schools_form][:organisation_ids].count
                    end
    readable_job_location = readable_job_location(job_location, school_name: school_name, schools_count: schools_count)
    attributes_to_merge = {
      completed_steps: completed_steps,
      job_location: job_location,
      readable_job_location: readable_job_location,
    }
    params.require(:publishers_job_listing_schools_form)
          .permit(:organisation_ids, organisation_ids: [])
          .merge(attributes_to_merge.compact)
  end

  def job_details_params(params)
    job_location = vacancy.job_location.presence || "at_one_school"
    readable_job_location = vacancy.readable_job_location.presence || readable_job_location(job_location, school_name: current_organisation.name)
    attributes_to_merge = {
      completed_steps: completed_steps,
      job_location: job_location,
      readable_job_location: readable_job_location,
      organisation_ids: vacancy.organisation_ids.blank? ? current_organisation.id : nil,
      status: vacancy.status.blank? ? "draft" : nil,
    }
    params.require(:publishers_job_listing_job_details_form)
          .permit(:job_title, :contract_type, :contract_type_duration, working_patterns: [], subjects: [])
          .merge(attributes_to_merge.compact)
  end

  def pay_package_params(params)
    params.require(:publishers_job_listing_pay_package_form)
          .permit(:actual_salary, :salary, :benefits)
          .merge(completed_steps: completed_steps)
  end

  def important_dates_params(params)
    params.require(:publishers_job_listing_important_dates_form)
          .permit(:starts_asap, :starts_on, :publish_on, :publish_on_day, :expires_at, :expiry_time)
          .merge(completed_steps: completed_steps)
  end

  def applying_for_the_job_params(params)
    params.require(:publishers_job_listing_applying_for_the_job_form)
          .permit(:application_link, :enable_job_applications, :contact_email, :contact_number, :personal_statement_guidance, :school_visits, :how_to_apply)
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def job_summary_params(params)
    params.require(:publishers_job_listing_job_summary_form)
          .permit(:job_advert, :about_school).merge(completed_steps: completed_steps)
  end

  private

  def completed_steps
    defined_step = defined?(step) ? step : :review
    completed_step = params[:commit] == I18n.t("buttons.save_and_return_later") ? nil : defined_step.to_s
    (vacancy.completed_steps | [completed_step]).compact
  end
end
