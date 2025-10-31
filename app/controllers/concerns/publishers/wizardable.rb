module Publishers::Wizardable # rubocop:disable Metrics/ModuleLength
  STRIP_CHECKBOXES = {
    job_location: %i[organisation_ids],
    education_phases: %i[phases],
    key_stages: %i[key_stages],
    subjects: %i[subjects],
    contract_information: %i[working_patterns],
    pay_package: %i[salary_types],
  }.freeze

  private

  def job_location_params(params)
    organisation_ids = params[:publishers_job_listing_job_location_form][:organisation_ids]
    organisations = Organisation.where(id: organisation_ids)

    location_params = params.require(:publishers_job_listing_job_location_form)
          .permit(organisation_ids: [])

    school_phases = organisations.schools.map(&:phase).uniq
    vacancy_phases  = school_phases.select { |phase| phase.in? Vacancy::SCHOOL_PHASES_MATCHING_VACANCY_PHASES }

    if vacancy_phases.any? || organisations.schools.all?(&:school_group?)
      location_params.merge(phases: vacancy_phases)
    else
      location_params
    end
  end

  def job_role_params(params)
    params.fetch(:publishers_job_listing_job_role_form, {})
          .permit(job_roles: [])
  end

  def education_phases_params(params)
    params.require(:publishers_job_listing_education_phases_form)
          .permit(phases: [])
  end

  def job_title_params(params)
    params.require(:publishers_job_listing_job_title_form)
          .permit(:job_title)
  end

  def key_stages_params(params)
    params.require(:publishers_job_listing_key_stages_form)
          .permit(key_stages: [])
  end

  def subjects_params(params)
    params.require(:publishers_job_listing_subjects_form)
          .permit(subjects: [])
  end

  def contract_information_params(params)
    params.require(:publishers_job_listing_contract_information_form)
          .permit(:working_patterns_details, :is_job_share, :contract_type, :fixed_term_contract_duration, :is_parental_leave_cover, working_patterns: [])
  end

  def pay_package_params(params)
    params.require(:publishers_job_listing_pay_package_form)
          .permit(:actual_salary, :benefits, :benefits_details, :salary, :pay_scale, :hourly_rate, salary_types: [])
  end

  def important_dates_params(params)
    params.require(:publishers_job_listing_important_dates_form)
          .permit(:publish_on, :publish_on_day, :expires_at, :expiry_time)
  end

  def start_date_params(params)
    params.require(:publishers_job_listing_start_date_form)
          .permit(:start_date_type, :starts_on, :earliest_start_date, :latest_start_date, :other_start_date_details)
  end

  def applying_for_the_job_params(params)
    if params[:publishers_job_listing_applying_for_the_job_form]
      params.require(:publishers_job_listing_applying_for_the_job_form)
            .permit(:application_form_type)
    else
      {}
    end.merge(current_organisation: current_organisation)
  end

  def how_to_receive_applications_params(params)
    if params[:publishers_job_listing_how_to_receive_applications_form]
      params.require(:publishers_job_listing_how_to_receive_applications_form)
            .permit(:receive_applications)
    else
      {}
    end.merge(current_organisation: current_organisation)
  end

  def application_link_params(params)
    params.require(:publishers_job_listing_application_link_form)
          .permit(:application_link)
          .merge(current_organisation: current_organisation)
  end

  def school_visits_params(params)
    if params[:publishers_job_listing_school_visits_form]
      params.require(:publishers_job_listing_school_visits_form)
            .permit(:school_visits)
    else
      {}
    end.merge(current_organisation: current_organisation)
  end

  def visa_sponsorship_params(params)
    if params[:publishers_job_listing_visa_sponsorship_form]
      params.require(:publishers_job_listing_visa_sponsorship_form)
            .permit(:visa_sponsorship_available)
    else
      {}
    end.merge(current_organisation: current_organisation)
  end

  def contact_details_params(params)
    params.require(:publishers_job_listing_contact_details_form)
          .permit(:contact_email, :other_contact_email, :contact_number, :contact_number_provided)
          .merge(current_organisation: current_organisation)
  end

  def confirm_contact_details_params(params)
    if params[:publishers_job_listing_confirm_contact_details_form]
      params.require(:publishers_job_listing_confirm_contact_details_form)
            .permit(:confirm_contact_email)
    else
      {}
    end
  end

  def about_the_role_params(params)
    params.require(:publishers_job_listing_about_the_role_form)
          .permit(:ect_status, :skills_and_experience, :school_offer, :flexi_working, :flexi_working_details_provided,
                  :further_details_provided, :further_details)
  end

  def include_additional_documents_params(params)
    if params[:publishers_job_listing_include_additional_documents_form]
      params.require(:publishers_job_listing_include_additional_documents_form)
            .permit(:include_additional_documents)
    else
      {}
    end
  end

  def anonymise_applications_params(params)
    if params[:publishers_job_listing_anonymise_applications_form]
      params.require(:publishers_job_listing_anonymise_applications_form)
            .permit(:anonymise_applications)
    else
      {}
    end
  end

  # Returns an array of completed steps, adding the current step and removing any steps that need to be reset
  def completed_steps(steps_to_reset: [])
    (vacancy.completed_steps | [current_step.to_s]).compact - steps_to_reset.map(&:to_s)
  end

  def current_step
    step if defined?(step)
  end
end
