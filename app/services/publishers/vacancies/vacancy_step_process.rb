class Publishers::Vacancies::VacancyStepProcess < StepProcess
  attr_reader :vacancy, :organisation

  def initialize(current_step, vacancy:, organisation:)
    @vacancy = vacancy
    @organisation = organisation

    super(current_step, {
      job_role: job_role_steps,
      job_location: job_location_steps,
      job_details: job_details_steps,
      working_patterns: %i[working_patterns],
      pay_package: %i[pay_package],
      important_dates: %i[important_dates],
      applying_for_the_job: applying_for_the_job_steps,
      documents: %i[documents],
      job_summary: %i[job_summary],
      review: %i[review],
    })
  end

  private

  def job_role_steps
    if vacancy.teacher?
      %i[job_role job_role_details]
    else
      %i[job_role]
    end
  end

  def job_location_steps
    return [] if organisation.school?

    %i[job_location]
  end

  def job_details_steps
    if vacancy.allow_phase_to_be_set?
      %i[education_phases job_details]
    else
      %i[job_details]
    end
  end

  def applying_for_the_job_steps
    if vacancy.published? || organisation.local_authority?
      %i[applying_for_the_job_details]
    else
      %i[applying_for_the_job applying_for_the_job_details]
    end
  end
end
