module Publishers::Wizardable
  STRIP_CHECKBOXES = {
    job_location: %i[organisation_ids],
    education_phases: %i[phases],
    job_details: %i[subjects key_stages],
    working_patterns: %i[working_patterns],
    pay_package: %i[salary_types],
  }.freeze

  private

  def job_role_params(params)
    params.require(:publishers_job_listing_job_role_form).permit(:job_role).merge(completed_steps: completed_steps)
  end

  def job_role_details_params(params)
    params.require(:publishers_job_listing_job_role_details_form)
          .permit(:ect_status)
          .merge(completed_steps: completed_steps)
  end

  def job_location_params(params)
    organisation_ids = params[:publishers_job_listing_job_location_form][:organisation_ids]
    organisations = Organisation.where(id: organisation_ids)

    params.require(:publishers_job_listing_job_location_form)
          .permit(organisation_ids: [])
          .merge(phases: organisations.schools.filter_map(&:readable_phase).uniq)
          .merge(completed_steps: completed_steps)
  end

  def education_phases_params(params)
    params.require(:publishers_job_listing_education_phases_form)
          .permit(phases: [])
          .merge(completed_steps: completed_steps)
  end

  def job_details_params(params)
    params.require(:publishers_job_listing_job_details_form)
          .permit(:job_title, :contract_type, :fixed_term_contract_duration, :parental_leave_cover_contract_duration, key_stages: [], subjects: [])
          .merge(completed_steps: completed_steps, status: vacancy.status || "draft")
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
          .permit(:start_date_type, :starts_on, :earliest_start_date, :latest_start_date, :other_start_date_details, :publish_on, :publish_on_day, :expires_at, :expiry_time)
          .merge(completed_steps: completed_steps)
  end

  def applying_for_the_job_params(params)
    if params[:publishers_job_listing_applying_for_the_job_form]
      params.require(:publishers_job_listing_applying_for_the_job_form).permit(:enable_job_applications)
    else
      {}
    end.merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def applying_for_the_job_details_params(params)
    params.require(:publishers_job_listing_applying_for_the_job_details_form)
          .permit(:application_link, :contact_email, :contact_number, :personal_statement_guidance, :school_visits, :how_to_apply)
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def job_summary_params(params)
    params.require(:publishers_job_listing_job_summary_form)
          .permit(:job_advert, :about_school)
          .merge(completed_steps: completed_steps)
  end

  def completed_steps
    (vacancy.completed_steps | [(current_step || "review").to_s]).compact
  end

  def current_step
    step if defined?(step)
  end
end
