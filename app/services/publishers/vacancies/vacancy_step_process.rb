class Publishers::Vacancies::VacancyStepProcess < StepProcess
  attr_reader :vacancy, :organisation

  def initialize(current_step, vacancy:, organisation:)
    @vacancy = vacancy
    @organisation = organisation

    super(current_step, {
      job_details: job_details_steps,
      important_dates: %i[important_dates start_date],
      application_process: application_process_steps,
      about_the_role: about_the_role_steps,
      review: %i[review],
    })
  end

  private

  def job_details_steps
    steps = %i[job_location job_role education_phases job_title key_stages subjects contract_type working_patterns pay_package]
    steps.delete(:job_location) if organisation.school?
    steps.delete(:education_phases) unless vacancy.allow_phase_to_be_set?
    steps.delete(:key_stages) unless vacancy.allow_key_stages?
    steps.delete(:subjects) unless vacancy.allow_subjects?

    steps
  end

  def application_process_steps
    if vacancy.published? || organisation.local_authority?
      steps = %i[school_visits contact_details]
      steps.insert(0, :how_to_receive_applications) unless vacancy.enable_job_applications
      steps.insert(1, application_method) if application_method.present?
    else
      steps = %i[applying_for_the_job school_visits contact_details]
      steps.insert(1, :how_to_receive_applications) unless vacancy.enable_job_applications
      steps.insert(2, application_method) if application_method.present?
    end

    steps
  end

  def about_the_role_steps
    steps = %i[about_the_role include_additional_documents documents]
    steps.delete(:documents) unless vacancy.include_additional_documents

    steps
  end

  def application_method
    return if vacancy.enable_job_applications

    case vacancy.receive_applications
    when "email"
      :application_form
    when "website"
      :application_link
    end
  end
end
