class Publishers::VacancyFormPageHeadingComponent < ViewComponent::Base
  delegate :current_organisation, to: :helpers
  delegate :current_step_number, to: :helpers
  delegate :total_steps, to: :helpers

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def heading
    page_title
  end

  def show_current_step?
    %w[copy edit edit_published].exclude?(vacancy.state)
  end

private

  attr_reader :vacancy

  def page_title
    return I18n.t("jobs.copy_job_title", job_title: vacancy.job_title) if vacancy.state == "copy"
    return I18n.t("jobs.create_a_job_title", organisation: organisation_from_job_location) if
      %w[create review].include?(vacancy.state)

    I18n.t("jobs.edit_job_title", job_title: vacancy.job_title)
  end

  def organisation_from_job_location
    vacancy.job_location == "at_multiple_schools" ? "multiple schools" : vacancy.parent_organisation_name
  end
end
