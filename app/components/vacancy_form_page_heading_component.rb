class VacancyFormPageHeadingComponent < ApplicationComponent
  delegate :current_organisation, to: :helpers
  attr_reader :sub_caption

  def initialize(vacancy, step_process, heading: nil, sub_caption: {})
    @vacancy = vacancy
    @step_process = step_process
    @sub_caption = sub_caption
    @heading = heading
  end

  def heading_class
    "govuk-heading-l"
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
