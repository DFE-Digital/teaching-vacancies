class VacancyFormPageHeadingComponent < ViewComponent::Base
  delegate :current_organisation, to: :helpers

  def initialize(vacancy, step_process, params: {}, fieldset: true)
    @vacancy = vacancy
    @step_process = step_process
    @params = params
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

  private

  attr_reader :vacancy, :copy, :step_process

  def page_title_from_vacancy_organisations
    return current_organisation.name if vacancy.organisations.none?

    vacancy.organisations.many? ? "multiple schools" : vacancy.organisation_name
  end

  def back_path
    if params[:back_to_review] == "true"
      organisation_job_review_path(vacancy.id)
    elsif params[:back_to_show] == "true"
      organisation_job_path(vacancy.id)
    elsif step_process.previous_step
      organisation_job_build_path(vacancy.id, step_process.previous_step)
    else
      jobs_with_type_organisation_path(:published)
    end
  end
end
