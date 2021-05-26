module Publishers::Wizardable
  STRIP_CHECKBOXES = {
    schools: %i[organisation_ids],
    job_details: %i[job_roles subjects working_patterns],
  }.freeze

  def steps_config
    {
      job_location: { number: 1, title: I18n.t("jobs.job_location") },
      schools: { number: 1, title: I18n.t("jobs.job_location") },
      job_details: { number: 2, title: I18n.t("jobs.job_details") },
      pay_package: { number: 3, title: I18n.t("jobs.pay_package") },
      important_dates: { number: 4, title: I18n.t("jobs.important_dates") },
      supporting_documents: { number: 5, title: I18n.t("jobs.supporting_documents") },
      applying_for_the_job: { number: 6, title: I18n.t("jobs.applying_for_the_job") },
      job_summary: { number: 7, title: I18n.t("jobs.job_summary") },
      review: { number: 8, title: I18n.t("jobs.review_heading") },
    }.freeze
  end

  def job_location_fields
    %i[job_location]
  end

  def schools_fields
    %i[organisation_ids]
  end

  def job_details_fields
    %i[job_title suitable_for_nqt contract_type contract_type_duration job_roles working_patterns subjects]
  end

  def pay_package_fields
    %i[salary benefits]
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

  def job_location_params(params)
    job_location = params[:publishers_job_listing_job_location_form][:job_location]
    readable_job_location = readable_job_location(
      job_location, school_name: current_organisation.name, schools_count: vacancy.organisation_ids.count
    )
    attributes_to_merge = {
      completed_step: steps_config[step][:number],
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
    params.require(:publishers_job_listing_schools_form)
          .permit(:organisation_ids, organisation_ids: [])
          .merge(completed_step: steps_config[step][:number], job_location: job_location, readable_job_location: readable_job_location)
  end

  def job_details_params(params)
    job_location = vacancy.job_location.presence || "at_one_school"
    readable_job_location = vacancy.readable_job_location.presence || readable_job_location(job_location, school_name: current_organisation.name)
    if params[:publishers_job_listing_job_details_form][:suitable_for_nqt] == "yes"
      params[:publishers_job_listing_job_details_form][:job_roles] |= [:nqt_suitable]
    end
    attributes_to_merge = {
      completed_step: steps_config[step][:number],
      job_location: job_location,
      readable_job_location: readable_job_location,
      organisation_ids: vacancy.organisation_ids.blank? ? current_organisation.id : nil,
      status: vacancy.status.blank? ? "draft" : nil,
    }
    params.require(:publishers_job_listing_job_details_form)
          .permit(:job_title, :suitable_for_nqt, :contract_type, :contract_type_duration, job_roles: [], working_patterns: [], subjects: [])
          .merge(attributes_to_merge.compact)
  end

  def pay_package_params(params)
    params.require(:publishers_job_listing_pay_package_form)
          .permit(:salary, :benefits).merge(completed_step: steps_config[step][:number])
  end

  def important_dates_params(params)
    params.require(:publishers_job_listing_important_dates_form)
          .permit(:starts_asap, :starts_on, :publish_on, :expires_at, :expiry_time)
          .merge(completed_step: steps_config[step][:number])
  end

  def applying_for_the_job_params(params)
    params.require(:publishers_job_listing_applying_for_the_job_form)
          .permit(:application_link, :enable_job_applications, :contact_email, :contact_number, :personal_statement_guidance, :school_visits, :how_to_apply)
          .merge(completed_step: steps_config[step][:number], current_organisation: current_organisation)
  end

  def job_summary_params(params)
    params.require(:publishers_job_listing_job_summary_form)
          .permit(:job_advert, :about_school).merge(completed_step: steps_config[step][:number])
  end
end
