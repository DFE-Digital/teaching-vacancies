module OrganisationHelpers
  def has_profile_summary?(page, organisation)
    expect(page).to have_content(organisation.name)
    expect(page).to have_content(full_address(organisation)) if organisation.postcode?
    expect(page).to have_content(organisation_type_basic(organisation).humanize)
    expect(page).to have_content(organisation.phase.humanize) if organisation.phase?

    expect(page).to have_content(age_range(organisation)) if organisation.minimum_age? && organisation.maximum_age?
    expect(page).to have_content(school_size(organisation)) if organisation.school? && school_has_school_size_data?(organisation)
    expect(page).to have_link(href: organisation.url) if organisation.url?
  end

  def has_list_of_live_jobs?(page, vacancies)
    vacancies.each do |vacancy|
      expect(page).to have_link(vacancy.job_title, href: Rails.application.routes.url_helpers.job_path(vacancy))
    end
  end

  def has_button_to_create_job_alert?(page, organisation)
    expect(page).to have_link(I18n.t("organisations.show.job_alert.button"), href: Rails.application.routes.url_helpers.new_subscription_path(search_criteria: { organisation_slug: organisation.slug }))
  end
end
