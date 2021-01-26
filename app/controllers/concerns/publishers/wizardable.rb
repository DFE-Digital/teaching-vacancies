module Publishers::Wizardable
  FORMS = {
    job_location: Publishers::JobListing::JobLocationForm,
    schools: Publishers::JobListing::SchoolsForm,
    job_details: Publishers::JobListing::JobDetailsForm,
    pay_package: Publishers::JobListing::PayPackageForm,
    important_dates: Publishers::JobListing::ImportantDatesForm,
    documents: Publishers::JobListing::DocumentsForm,
    applying_for_the_job: Publishers::JobListing::ApplyingForTheJobForm,
    job_summary: Publishers::JobListing::JobSummaryForm,
  }.freeze

  FORM_PARAMS = {
    job_location: :job_location_params,
    schools: :schools_params,
    job_details: :job_details_params,
    pay_package: :pay_package_params,
    important_dates: :important_dates_params,
    documents: :documents_params,
    applying_for_the_job: :applying_for_the_job_params,
    job_summary: :job_summary_params,
  }.freeze

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
      documents: { number: 5, title: I18n.t("jobs.supporting_documents") },
      applying_for_the_job: { number: 6, title: I18n.t("jobs.applying_for_the_job") },
      job_summary: { number: 7, title: I18n.t("jobs.job_summary") },
      review: { number: 8, title: I18n.t("jobs.review_heading") },
    }.freeze
  end

  def job_location_params(params)
    job_location = params[:publishers_job_listing_job_location_form][:job_location]
    readable_job_location = readable_job_location(
      job_location, school_name: current_organisation.name, schools_count: @vacancy.organisation_ids.count
    )
    attributes_to_merge = {
      completed_step: steps_config[step][:number],
      readable_job_location: job_location == "central_office" ? readable_job_location : nil,
      organisation_ids: job_location == "central_office" ? current_organisation.id : nil,
    }
    session[:job_location] = job_location
    params.require(:publishers_job_listing_job_location_form)
          .permit(:state, :job_location).merge(attributes_to_merge.compact)
  end

  def schools_params(params)
    job_location = session[:job_location].presence || @vacancy.job_location
    school_name = if params[:publishers_job_listing_schools_form][:organisation_ids].is_a?(String)
                    School.find(params[:publishers_job_listing_schools_form][:organisation_ids]).name
                  end
    schools_count = if params[:publishers_job_listing_schools_form][:organisation_ids].is_a?(Array)
                      params[:publishers_job_listing_schools_form][:organisation_ids].count
                    end
    readable_job_location = readable_job_location(job_location, school_name: school_name, schools_count: schools_count)
    params.require(:publishers_job_listing_schools_form)
          .permit(:state, :organisation_ids, organisation_ids: [])
          .merge(completed_step: steps_config[step][:number], job_location: job_location, readable_job_location: readable_job_location)
  end

  def job_details_params(params)
    job_location = @vacancy.job_location.presence || "at_one_school"
    readable_job_location = @vacancy.readable_job_location.presence || readable_job_location(job_location, school_name: current_organisation.name)
    if params[:publishers_job_listing_job_details_form][:suitable_for_nqt] == "yes"
      params[:publishers_job_listing_job_details_form][:job_roles] |= [:nqt_suitable]
    end
    attributes_to_merge = {
      completed_step: steps_config[step][:number],
      job_location: job_location,
      readable_job_location: readable_job_location,
      organisation_ids: @vacancy.organisation_ids.blank? ? current_organisation.id : nil,
      status: @vacancy.status.blank? ? "draft" : nil,
    }
    params.require(:publishers_job_listing_job_details_form)
          .permit(:state, :job_title, :suitable_for_nqt, :contract_type, :contract_type_duration, job_roles: [], working_patterns: [], subjects: [])
          .merge(attributes_to_merge.compact)
  end

  def pay_package_params(params)
    params.require(:publishers_job_listing_pay_package_form)
          .permit(:state, :salary, :benefits).merge(completed_step: steps_config[step][:number])
  end

  def important_dates_params(params)
    params.require(:publishers_job_listing_important_dates_form)
          .permit(:state, :starts_asap, :starts_on, :publish_on, :expires_on,
                  :expires_at, :expires_at_hh, :expires_at_mm, :expires_at_meridiem).merge(completed_step: steps_config[step][:number])
  end

  def applying_for_the_job_params(params)
    params.require(:publishers_job_listing_applying_for_the_job_form)
          .permit(:state, :application_link, :contact_email, :contact_number, :school_visits, :how_to_apply)
          .merge(completed_step: steps_config[step][:number])
  end

  def job_summary_params(params)
    params.require(:publishers_job_listing_job_summary_form)
          .permit(:state, :job_summary, :about_school).merge(completed_step: steps_config[step][:number])
  end
end
