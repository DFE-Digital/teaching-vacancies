class VacancyFormPageFieldsetComponent < ApplicationComponent
  def initialize(vacancy, step_process, heading: nil)
    super()
    @vacancy = vacancy
    @step_process = step_process
    @heading = heading
  end

  def heading
    @heading.presence || t("publishers.vacancies.steps.#{step_process.current_step}")
  end

  def caption
    if vacancy.published?
      t("jobs.edit_job_caption", step: step_process.current_step_group_number, total: 4)
    else
      t("jobs.create_job_caption", step: step_process.current_step_group_number, total: 4)
    end
  end

  private

  attr_reader :vacancy, :step_process
end
