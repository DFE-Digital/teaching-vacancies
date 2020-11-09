class HiringStaff::VacancyFormPageHeadingComponent < ViewComponent::Base
  delegate :current_organisation, to: :helpers
  delegate :current_step, to: :helpers
  delegate :total_steps, to: :helpers

  def initialize(vacancy, session_vacancy_attributes)
    unless session_vacancy_attributes.nil?
      @session_job_location = session_vacancy_attributes["job_location"]
      @session_readable_job_location = session_vacancy_attributes["readable_job_location"]
    end
    @vacancy = vacancy
  end

  def heading
    vacancy.present? ? page_title : page_title_no_vacancy
  end

  def show_current_step?
    %w[copy edit edit_published].exclude?(vacancy&.state)
  end

private

  attr_reader :session_job_location, :session_readable_job_location, :vacancy

  def page_title_no_vacancy
    return I18n.t("jobs.create_a_job_title_no_org") unless current_organisation.is_a?(School) || current_step > 1

    organisation_for_title =
      if session_job_location == "at_one_school"
        session_readable_job_location
      elsif session_job_location == "at_multiple_schools"
        "multiple schools"
      else
        current_organisation.name
      end

    organisation_for_title ? I18n.t("jobs.create_a_job_title", organisation: organisation_for_title) : I18n.t("jobs.create_a_job_title_no_org")
  end

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
