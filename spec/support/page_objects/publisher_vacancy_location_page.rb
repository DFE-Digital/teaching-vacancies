class PublisherVacancyLocationPage < SitePrism::Page
  set_url "/publishers/organisations/{organisation_id}/vacancies/{vacancy_id}/job-location"

  set_url "/publishers/organisations/{organisation_id}/vacancies/{vacancy_id}/job-location"

  element :continue_button, "input[value='#{I18n.t('buttons.continue')}']"
  element :error_summary, ".govuk-error-summary"

  def continue
    continue_button.click
  end

  def has_location_error?
    error_summary.has_text?(I18n.t("job_location_errors.organisation_ids.blank"))
  end

  def fill_form(vacancy)
    vacancy.organisations.each do |organisation|
      check(organisation.school? ? organisation.name : I18n.t("organisations.job_location_heading.central_office"))
    end
  end
end
