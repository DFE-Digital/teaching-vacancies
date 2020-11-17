module HiringStaff::Wizardable
  STEPS = {
    job_location: 1,
    schools: 1,
    job_details: 2,
    pay_package: 3,
    important_dates: 4,
    supporting_documents: 5,
    documents: 5,
    applying_for_the_job: 6,
    job_summary: 7,
    review: 8,
  }.freeze

  VACANCY_FORMS = {
    job_location: JobLocationForm,
    schools: SchoolsForm,
    job_details: JobDetailsForm,
    pay_package: PayPackageForm,
    important_dates: ImportantDatesForm,
    supporting_documents: SupportingDocumentsForm,
    documents: DocumentsForm,
    applying_for_the_job: ApplyingForTheJobForm,
    job_summary: JobSummaryForm,
  }.freeze

  VACANCY_FORM_PARAMS = {
    job_location: :job_location_params,
    schools: :schools_params,
    job_details: :job_details_params,
    pay_package: :pay_package_params,
    important_dates: :important_dates_params,
    supporting_documents: :supporting_documents_params,
    documents: :documents_params,
    applying_for_the_job: :applying_for_the_job_params,
    job_summary: :job_summary_params,
  }.freeze

  VACANCY_STRIP_CHECKBOXES = {
    schools: %i[organisation_ids],
    job_details: %i[job_roles subjects working_patterns],
  }.freeze

  def job_location_params(params)
    job_location = params[:job_location_form][:job_location]
    readable_job_location = readable_job_location(
      job_location, school_name: current_organisation.name, schools_count: @vacancy.organisation_ids.count
    )
    attributes_to_merge = {
      completed_step: STEPS[step],
      readable_job_location: readable_job_location,
      organisation_ids: job_location == "central_office" ? current_organisation.id : nil,
    }
    params.require(:job_location_form).permit(:state, :job_location).merge(attributes_to_merge.compact)
  end

  def schools_params(params)
    job_location = @vacancy.job_location
    school_name = if params[:schools_form][:organisation_ids].is_a?(String)
                    School.find(params[:schools_form][:organisation_ids]).name
                  end
    schools_count = if params[:schools_form][:organisation_ids].is_a?(Array)
                      params[:schools_form][:organisation_ids].count
                    end
    readable_job_location = readable_job_location(job_location, school_name: school_name, schools_count: schools_count)
    params.require(:schools_form)
          .permit(:state, :organisation_ids, organisation_ids: [])
          .merge(completed_step: STEPS[step], job_location: job_location, readable_job_location: readable_job_location)
  end

  def job_details_params(params)
    job_location = @vacancy.job_location.presence || "at_one_school"
    readable_job_location = @vacancy.readable_job_location.presence || readable_job_location(job_location, school_name: current_organisation.name)
    if params[:job_details_form][:suitable_for_nqt] == "yes"
      params[:job_details_form][:job_roles] |= [:nqt_suitable]
    end
    attributes_to_merge = {
      completed_step: STEPS[step],
      job_location: job_location,
      readable_job_location: readable_job_location,
      organisation_ids: @vacancy.organisation_ids.blank? ? current_organisation.id : nil,
      status: @vacancy.status.blank? ? "draft" : nil,
    }
    params.require(:job_details_form)
          .permit(:state, :job_title, :suitable_for_nqt, job_roles: [], working_patterns: [], subjects: [])
          .merge(attributes_to_merge.compact)
  end

  def pay_package_params(params)
    params.require(:pay_package_form).permit(:state, :salary, :benefits).merge(completed_step: STEPS[step])
  end

  def important_dates_params(params)
    params.require(:important_dates_form)
          .permit(:state, :starts_on, :publish_on, :expires_on,
                  :expires_at, :expires_at_hh, :expires_at_mm, :expires_at_meridiem).merge(completed_step: STEPS[step])
  end

  def supporting_documents_params(params)
    params.require(:supporting_documents_form).permit(:state, :supporting_documents).merge(completed_step: STEPS[step])
  end

  def applying_for_the_job_params(params)
    params.require(:applying_for_the_job_form)
          .permit(:state, :application_link, :contact_email, :contact_number, :school_visits, :how_to_apply)
          .merge(completed_step: STEPS[step])
  end

  def job_summary_params(params)
    params.require(:job_summary_form).permit(:state, :job_summary, :about_school).merge(completed_step: STEPS[step])
  end
end
