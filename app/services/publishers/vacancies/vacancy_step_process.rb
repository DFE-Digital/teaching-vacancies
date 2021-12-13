class Publishers::Vacancies::VacancyStepProcess < StepProcess
  attr_reader :vacancy, :organisation, :session

  def initialize(current_step, vacancy:, organisation:, session: {})
    @vacancy = vacancy
    @organisation = organisation
    @session = session

    super(current_step, {
      job_role: job_role_steps,
      job_location: job_location_steps,
      job_details: job_details_steps,
      working_patterns: %i[working_patterns],
      pay_package: %i[pay_package],
      important_dates: %i[important_dates],
      documents: %i[documents],
      applying_for_the_job: applying_for_the_job_steps,
      job_summary: %i[job_summary],
      review: %i[review],
    })
  end

  def previous_step_or_review
    return steps.last if session[:current_step] == :review && first_of_group?

    previous_step
  end

  private

  def job_role_steps
    if vacancy.main_job_role == "sendco"
      %i[job_role]
    else
      %i[job_role job_role_details]
    end
  end

  def job_location_steps
    return nil if organisation.school?

    most_up_to_date_job_location = session[:job_location].presence || vacancy.job_location
    if most_up_to_date_job_location == "central_office"
      %i[job_location]
    else
      %i[job_location schools]
    end
  end

  def job_details_steps
    if vacancy.allow_phase_to_be_set?
      %i[education_phases job_details]
    else
      %i[job_details]
    end
  end

  def applying_for_the_job_steps
    %i[applying_for_the_job applying_for_the_job_details]
  end
end
