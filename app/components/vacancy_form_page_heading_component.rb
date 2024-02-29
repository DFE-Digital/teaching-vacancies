class VacancyFormPageHeadingComponent < ViewComponent::Base
  delegate :current_organisation, to: :helpers

  def initialize(vacancy, step_process, back_path:, fieldset: true)
    @vacancy = vacancy
    @step_process = step_process
    @back_path = back_path
    @fieldset = fieldset
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

  def sub_caption
    step_process.current_step == :job_role ? "Select all that apply" : nil
  end

  def sub_caption_class
    step_process.current_step == :job_role ? "govuk-!-margin-top-4 govuk-!-margin-bottom-4" : nil
  end

  private

  attr_reader :vacancy, :copy, :step_process, :back_path

  def page_title_from_vacancy_organisations
    return current_organisation.name if vacancy.organisations.none?

    vacancy.organisations.many? ? "multiple schools" : vacancy.organisation_name
  end
end
