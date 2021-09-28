class Publishers::Vacancies::VacancyStepProcess < StepProcess
  attr_reader :vacancy, :organisation, :session

  def initialize(current_step, vacancy:, organisation:, session:)
    @vacancy = vacancy
    @organisation = organisation
    @session = session

    super(current_step, {
      job_role: job_role_steps,
      job_location: job_location_steps,
      job_details: %i[job_details],
      working_patterns: %i[working_patterns],
      pay_package: %i[pay_package],
      important_dates: %i[important_dates],
      documents: %i[documents],
      applying_for_the_job: %i[applying_for_the_job],
      job_summary: %i[job_summary],
      review: %i[review],
    })
  end

  def validatable_steps
    steps - %i[documents review]
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

    job_location_changed_in_session = session[:job_location].present? && session[:job_location] != vacancy.job_location

    if vacancy.job_location == "central_office" && !job_location_changed_in_session
      %i[job_location]
    else
      %i[job_location schools]
    end
  end
end
