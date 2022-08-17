module Publishers::Wizardable
  STRIP_CHECKBOXES = {
    job_location: %i[organisation_ids],
    education_phases: %i[phases],
    key_stages: %i[key_stages],
    subjects: %i[subjects],
    working_patterns: %i[working_patterns],
    pay_package: %i[salary_types],
  }.freeze

  private

  def job_location_params(params)
    organisation_ids = params[:publishers_job_listing_job_location_form][:organisation_ids]
    organisations = Organisation.where(id: organisation_ids)

    params.require(:publishers_job_listing_job_location_form)
          .permit(organisation_ids: [])
          .merge(phases: organisations.schools.filter_map(&:readable_phase).uniq)
          .merge(completed_steps: completed_steps)
  end

  def job_role_params(params)
    params.require(:publishers_job_listing_job_role_form)
          .permit(:job_role)
          .merge(completed_steps: completed_steps)
  end

  def education_phases_params(params)
    params.require(:publishers_job_listing_education_phases_form)
          .permit(phases: [])
          .merge(completed_steps: completed_steps)
  end

  def job_title_params(params)
    params.require(:publishers_job_listing_job_title_form)
          .permit(:job_title)
          .merge(completed_steps: completed_steps, status: vacancy.status || "draft")
  end

  def key_stages_params(params)
    params.require(:publishers_job_listing_key_stages_form)
          .permit(key_stages: [])
          .merge(completed_steps: completed_steps)
  end

  def subjects_params(params)
    params.require(:publishers_job_listing_subjects_form)
          .permit(subjects: [])
          .merge(completed_steps: completed_steps)
  end

  def contract_type_params(params)
    params.require(:publishers_job_listing_contract_type_form)
          .permit(:contract_type, :fixed_term_contract_duration, :parental_leave_cover_contract_duration)
          .merge(completed_steps: completed_steps)
  end

  def working_patterns_params(params)
    params.require(:publishers_job_listing_working_patterns_form)
          .permit(:full_time_details, :part_time_details, working_patterns: [])
          .merge(completed_steps: completed_steps)
  end

  def pay_package_params(params)
    params.require(:publishers_job_listing_pay_package_form)
          .permit(:actual_salary, :benefits, :benefits_details, :salary, :pay_scale, salary_types: [])
          .merge(completed_steps: completed_steps)
  end

  def important_dates_params(params)
    params.require(:publishers_job_listing_important_dates_form)
          .permit(:publish_on, :publish_on_day, :expires_at, :expiry_time)
          .merge(completed_steps: completed_steps)
  end

  def start_date_params(params)
    params.require(:publishers_job_listing_start_date_form)
          .permit(:start_date_type, :starts_on, :earliest_start_date, :latest_start_date, :other_start_date_details)
          .merge(completed_steps: completed_steps)
  end

  def applying_for_the_job_params(params)
    if params[:publishers_job_listing_applying_for_the_job_form]
      params.require(:publishers_job_listing_applying_for_the_job_form)
            .permit(:enable_job_applications)
    else
      {}
    end.merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def how_to_receive_applications_params(params)
    if params[:publishers_job_listing_how_to_receive_applications_form]
      params.require(:publishers_job_listing_how_to_receive_applications_form)
            .permit(:receive_applications)
    else
      {}
    end.merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def application_link_params(params)
    params.require(:publishers_job_listing_application_link_form)
          .permit(:application_link)
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def application_form_params(params)
    params.require(:publishers_job_listing_application_form_form)
          .permit(:application_email, :other_application_email)
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def school_visits_params(params)
    if params[:publishers_job_listing_school_visits_form]
      params.require(:publishers_job_listing_school_visits_form)
            .permit(:school_visits)
    else
      {}
    end.merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def contact_details_params(params)
    params.require(:publishers_job_listing_contact_details_form)
          .permit(:contact_email, :other_contact_email, :contact_number, :contact_number_provided)
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def about_the_role_params(params)
    params.require(:publishers_job_listing_about_the_role_form)
          .permit(:ect_status, :skills_and_experience, :school_offer, :safeguarding_information_provided, :safeguarding_information, :further_details_provided, :further_details)
          .merge(completed_steps: completed_steps)
  end

  def include_additional_documents_params(params)
    if params[:publishers_job_listing_include_additional_documents_form]
      params.require(:publishers_job_listing_include_additional_documents_form)
            .permit(:include_additional_documents)
    else
      {}
    end.merge(completed_steps: completed_steps)
  end

  def completed_steps
    (vacancy.completed_steps | [current_step.to_s]).compact
  end

  def current_step
    step if defined?(step)
  end
end
