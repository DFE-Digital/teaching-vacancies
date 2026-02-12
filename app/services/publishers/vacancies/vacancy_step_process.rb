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

  def all_steps_valid?
    validatable_steps.all? { |step| step_form(step).valid? }
  end

  def next_invalid_step
    # Due to subjects being an optional step (no validations) it needs to be handled differently
    return :subjects if next_incomplete_step_subjects?

    validatable_steps.detect { |step| step_form(step).invalid? }
  end

  private

  def job_details_steps
    first = if organisation.school?
              %i[job_title job_role]
            else
              %i[job_location job_title job_role]
            end
    phases = vacancy.allow_phase_to_be_set? ? %i[education_phases] : []
    stages = vacancy.allow_key_stages? ? %i[key_stages] : []
    last = if vacancy.allow_subjects?
             %i[subjects contract_information start_date pay_package]
           else
             %i[contract_information start_date pay_package]
           end
    first + phases + stages + last
  end

  def application_process_steps
    # if the user enters a contact email that doesn't belong to a publisher in our service we want to make them confirm it.
    early_steps = vacancy.published? ? [] : %i[applying_for_the_job]

    start_steps = if vacancy.enable_job_applications
                    early_steps + %i[anonymise_applications]
                  else
                    first_steps = early_steps + %i[how_to_receive_applications]
                    # receive_applications may not be present (yet) as it is asked in how_to_receive_applications
                    if vacancy.receive_applications.present?
                      last_steps = vacancy.uploaded_form? ? %i[anonymise_applications] : []
                      first_steps + [APPLICATION_METHOD_TO_STEP.fetch(vacancy.receive_applications.to_sym)] + last_steps
                    else
                      first_steps
                    end
                  end
    start_steps + %i[contact_details confirm_contact_details]
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

  def next_incomplete_step_subjects?
    return false unless @vacancy.allow_subjects?
    return false if @vacancy.completed_steps.include?("subjects")

    @vacancy.completed_steps.last == if @vacancy.allow_key_stages?
                                       "key_stages"
                                     else
                                       "job_role"
                                     end
  end

  def validatable_steps
    steps - %i[subjects review]
  end

  def step_form(step_name)
    step_form_class = "publishers/job_listing/#{step_name}_form".camelize.constantize

    step_form_class.load_from_model(@vacancy, current_publisher: nil)
  end
end
