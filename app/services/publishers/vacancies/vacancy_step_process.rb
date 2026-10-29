class Publishers::Vacancies::VacancyStepProcess < StepProcess
  attr_reader :vacancy, :organisation

  # StepProcess now takes a hash of hashes, with true if the step is valid and false otherwise
  # This allows the controller to skip non-relevant steps whilst understanding the full step sequence
  def initialize(current_step, vacancy:, organisation:)
    @vacancy = vacancy
    @organisation = organisation

    super(current_step, {
      job_details: job_details_steps,
      about_the_role: %i[about_the_role school_visits visa_sponsorship].index_with { true },
      important_dates: %i[important_dates].index_with { true },
      application_process: application_process_steps,
      review: %i[review].index_with { true },
    })
  end

  APPLICATION_METHOD_TO_STEP = {
    uploaded_form: :application_form,
    email: :application_form,
    website: :application_link,
  }.freeze

  private

  def job_details_steps
    %i[job_location job_title confirm_job_address job_role education_phases key_stages subjects contract_information start_date pay_package].index_with do |step|
      case step
      when :job_location
        @organisation.school_group?
      when :confirm_job_address
        vacancy.for_an_fe_college?
      when :education_phases
        vacancy.allow_phase_to_be_set?
      when :key_stages
        vacancy.allow_key_stages?
      when :subjects
        vacancy.allow_subjects?
      else
        true
      end
    end
  end

  def application_process_steps # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    initial_step = {
      applying_for_the_job: !(vacancy.published? || vacancy.for_an_fe_college?),
    }
    steps = if vacancy.enable_job_applications
              {
                how_to_receive_applications: false,
                application_form: false,
                application_link: false,
                anonymise_applications: true,
              }
            else
              {
                how_to_receive_applications: true,
                application_form: vacancy.receive_applications.present? && APPLICATION_METHOD_TO_STEP.fetch(vacancy.receive_applications.to_sym) == :application_form,
                application_link: vacancy.receive_applications.present? && APPLICATION_METHOD_TO_STEP.fetch(vacancy.receive_applications.to_sym) == :application_link,
                anonymise_applications: vacancy.uploaded_form?,
              }
            end

    initial_step.merge(steps)
                .merge(additional_documents_steps)
         .merge(contact_details: true, confirm_contact_details: true)
  end

  def additional_documents_steps
    {
      include_additional_documents: true,
      documents: vacancy.include_additional_documents,
    }
  end
end
