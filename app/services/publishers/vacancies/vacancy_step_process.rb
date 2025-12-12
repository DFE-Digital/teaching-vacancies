class Publishers::Vacancies::VacancyStepProcess < StepProcess
  attr_reader :vacancy, :organisation

  def initialize(current_step, vacancy:, organisation:)
    @vacancy = vacancy
    @organisation = organisation

    super(current_step, {
      job_details: job_details_steps,
      about_the_role: about_the_role_steps,
      important_dates: %i[important_dates],
      application_process: application_process_steps,
      review: %i[review],
    })
  end

  APPLICATION_METHOD_TO_STEP = {
    uploaded_form: :application_form,
    email: :application_form,
    website: :application_link,
  }.freeze

  private

  def job_details_steps
    steps = %i[job_location job_title job_role education_phases key_stages subjects contract_information start_date pay_package]
    steps.delete(:job_location) if organisation.school?
    steps.delete(:education_phases) unless vacancy.allow_phase_to_be_set?
    steps.delete(:key_stages) unless vacancy.allow_key_stages?
    steps.delete(:subjects) unless vacancy.allow_subjects?

    steps
  end

  def application_process_steps
    # if the user enters a contact email that doesn't belong to a publisher in our service we want to make them confirm it.
    core_steps = %i[contact_details confirm_contact_details]

    early_steps = if vacancy.published?
                    []
                  else
                    %i[applying_for_the_job]
                  end

    if vacancy.enable_job_applications
      early_steps + %i[anonymise_applications] + core_steps
    else
      first_steps = early_steps + %i[how_to_receive_applications]
      # receive_applications may not be present (yet) as it is asked in how_to_receive_applications
      if vacancy.receive_applications.present?
        first_steps + [APPLICATION_METHOD_TO_STEP.fetch(vacancy.receive_applications.to_sym)] + core_steps
      else
        first_steps + core_steps
      end
    end
  end

  def about_the_role_steps
    first_steps = %i[about_the_role include_additional_documents]
    last_steps = %i[school_visits visa_sponsorship]
    if vacancy.include_additional_documents
      first_steps + [:documents] + last_steps
    else
      first_steps + last_steps
    end
  end
end
