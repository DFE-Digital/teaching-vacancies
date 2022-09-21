class VacancyFormPageHeadingComponent < ViewComponent::Base
  delegate :current_organisation, to: :helpers

  def initialize(vacancy, step_process, params: {})
    @vacancy = vacancy
    @step_process = step_process
    @params = params
  end

  def heading
    page_title
  end

  private

  attr_reader :vacancy, :copy, :step_process

  def page_title
    return t("jobs.edit_job_title", job_title: vacancy.job_title) if vacancy.published?

    t("jobs.create_a_job_title", organisation: page_title_from_vacancy_organisations)
  end

  def page_title_from_vacancy_organisations
    return current_organisation.name if vacancy.organisations.none?

    vacancy.organisations.many? ? "multiple schools" : vacancy.organisation_name
  end

  def back_path
    return organisation_job_path(vacancy.id) if params[:back_to_review] == "true"

    organisation_job_build_path(vacancy.id, step_process.previous_step)
  end

  def render_back_link?
    steps_to_include_back_link = params[:back_to_review].present? ? step_process.steps : step_process.steps.excluding(:job_role)

    step_process.current_step.in?(steps_to_include_back_link)
  end
end
