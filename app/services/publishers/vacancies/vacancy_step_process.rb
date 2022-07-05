class Publishers::Vacancies::VacancyStepProcess < StepProcess
  attr_reader :vacancy, :organisation, :session

  def initialize(current_step, vacancy:, organisation:, session: {})
    @vacancy = vacancy
    @organisation = organisation
    @session = session

    super(current_step, {
      job_details: job_details_steps,
      important_dates: %i[important_dates],
      applying_for_the_job: applying_for_the_job_steps,
      documents: %i[documents],
      job_summary: %i[job_summary],
      review: %i[review],
    })
  end

  def previous_step_or_review
    return steps.last if session[:current_step] == :review && first_of_group?

    previous_step
  end

  private

  def job_details_steps
    steps = %i[job_location job_role education_phases job_title key_stages subjects contract_type working_patterns pay_package]
    steps.delete(:job_location) if organisation.school?
    steps.delete(:education_phases) unless vacancy.allow_phase_to_be_set?

    steps
  end

  def applying_for_the_job_steps
    if vacancy.published? || organisation.local_authority?
      %i[applying_for_the_job_details]
    else
      %i[applying_for_the_job applying_for_the_job_details]
    end
  end
end
