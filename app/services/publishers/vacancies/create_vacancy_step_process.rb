class Publishers::Vacancies::CreateVacancyStepProcess < StepProcess
  attr_reader :vacancy, :organisation

  def initialize(current_step, vacancy:, organisation:)
    @vacancy = vacancy
    @organisation = organisation

    create_vacancy_step_groups = {
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
    }

    super(current_step, create_vacancy_step_groups)
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

    if vacancy.job_location == "central_office"
      %i[job_location]
    else
      %i[job_location schools]
    end
  end
end
