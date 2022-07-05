module Publishers::Wizardable
  STRIP_CHECKBOXES = {
    job_location: %i[organisation_ids],
    key_stages: %i[key_stages],
    subjects: %i[subjects],
    working_patterns: %i[working_patterns],
    pay_package: %i[salary_types],
  }.freeze

  private

  def job_location_params(params)
    organisation_ids = params[:publishers_job_listing_job_location_form][:organisation_ids]
    school_name = if organisation_ids.count == 1
                    School.find(organisation_ids.first).name
                  end
    schools_count = organisation_ids.count
    readable_job_location = readable_job_location(organisation_ids, school_name: school_name, schools_count: schools_count)

    attributes_to_merge = {
      completed_steps: completed_steps,
      readable_job_location: readable_job_location,
      status: vacancy.status.blank? ? "draft" : nil,
    }

    params.require(:publishers_job_listing_job_location_form)
          .permit(organisation_ids: [])
          .merge(attributes_to_merge.compact)
  end

  def job_role_params(params)
    params.require(:publishers_job_listing_job_role_form).permit(:main_job_role).merge(completed_steps: completed_steps)
  end

  def education_phases_params(params)
    # Forms containing only radio buttons do not send the form key param when they're submitted and no radio is selected
    if params["publishers_job_listing_education_phases_form"]
      params.require(:publishers_job_listing_education_phases_form)
            .permit(:phase)
            .merge(completed_steps: completed_steps)
    else
      {}
    end
  end

  def job_title_params(params)
    params.require(:publishers_job_listing_job_title_form)
          .permit(:job_title)
          .merge(completed_steps: completed_steps)
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
          .permit(:working_patterns_details, working_patterns: [])
          .merge(completed_steps: completed_steps)
  end

  def pay_package_params(params)
    params.require(:publishers_job_listing_pay_package_form)
          .permit(:actual_salary, :salary, :pay_scale, salary_types: [])
          .merge(completed_steps: completed_steps)
  end

  def important_dates_params(params)
    params.require(:publishers_job_listing_important_dates_form)
          .permit(:starts_asap, :starts_on, :publish_on, :publish_on_day, :expires_at, :expiry_time)
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
