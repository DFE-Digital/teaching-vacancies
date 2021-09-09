class Publishers::VacancyFormPageHeadingComponent < ViewComponent::Base
  delegate :current_organisation, to: :helpers

  def initialize(vacancy, step_process)
    @vacancy = vacancy
    @step_process = step_process
  end

  def heading
    page_title
  end

  private

  attr_reader :vacancy, :copy

  def page_title
    return I18n.t("jobs.edit_job_title", job_title: vacancy.job_title) if vacancy.published?

    I18n.t("jobs.create_a_job_title", organisation: organisation_from_job_location)
  end

  def organisation_from_job_location
    vacancy.at_multiple_schools? ? "multiple schools" : vacancy.parent_organisation_name
  end
end
