class VacancyFormPageHeadingComponent < ViewComponent::Base
  delegate :current_organisation, to: :helpers

  def initialize(vacancy, step_process)
    @vacancy = vacancy
    @step_process = step_process
  end

  def heading
    page_title
  end

  private

  attr_reader :vacancy, :copy, :step_process

  def page_title
    return t("jobs.edit_job_title", job_title: vacancy.job_title) if vacancy.published?

    # t("jobs.create_a_job_title", organisation: organisation_from_job_location)
  end

  def organisation_from_job_location
    vacancy.at_multiple_schools? ? "multiple schools" : vacancy.organisation_name
  end

  def back_path
    if step_process.previous_step_or_review == :review
      return organisation_job_path(vacancy.id) if vacancy.completed_steps.size != step_process.steps.size

      organisation_job_review_path(vacancy.id)
    else
      organisation_job_build_path(vacancy.id, step_process.previous_step)
    end
  end
end
