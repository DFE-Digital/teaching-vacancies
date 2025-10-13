class VacancyFormPageHeadingComponent < ApplicationComponent
  delegate :current_organisation, to: :helpers
  attr_reader :sub_caption

  def initialize(vacancy, step_process, back_path:, fieldset: true, sub_caption: {})
    @vacancy = vacancy
    @step_process = step_process
    @back_path = back_path
    @fieldset = fieldset
    @sub_caption = sub_caption
  end

  def heading_class
    @fieldset ? "govuk-fieldset__heading" : "govuk-heading-l"
  end

  def heading
    t("publishers.vacancies.steps.#{step_process.current_step}")
  end

  def caption
    return t("jobs.edit_job_caption", step: step_process.current_step_group_number, total: step_process.total_step_groups - 1) if vacancy.published?

    t("jobs.create_job_caption", step: step_process.current_step_group_number, total: step_process.total_step_groups - 1)
  end

  private

  attr_reader :vacancy, :step_process, :back_path

  def page_title_from_vacancy_organisations
    return current_organisation.name if vacancy.organisations.none?

    vacancy.organisations.many? ? "multiple schools" : vacancy.organisation_name
  end
end
