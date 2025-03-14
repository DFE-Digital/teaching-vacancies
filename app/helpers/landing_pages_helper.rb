module LandingPagesHelper
  def landing_page_link_or_text(landing_page_criteria, text, match: :exact)
    lp = match == :exact ? LandingPage.matching(landing_page_criteria) : LandingPage.partially_matching(landing_page_criteria)
    return tag.span { text } unless lp

    text = match == :exact ? lp.name : landing_page_criteria.values.flatten.first
    link_text = t("landing_pages.accessible_link_text_html", name: text)
    govuk_link_to(link_text, landing_page_path(lp.slug), text_colour: true)
  end

  def linked_locations(vacancy)
    vacancy.location.last(2).map(&:parameterize).filter_map do |location|
      location = REDIRECTED_LOCATION_LANDING_PAGES[location] || location

      next unless location && LocationLandingPage.exists?(location)

      govuk_link_to(LocationLandingPage[location].name, location_landing_page_path(LocationLandingPage[location].location))
    end
  end

  def linked_job_roles_and_ect_status(vacancy)
    tag.ul class: "govuk-list" do
      safe_join(
        vacancy.job_roles.map { |role| tag.li(linked_job_role(I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{role}"))) }
                         .push(tag.li(linked_ect_status(vacancy))),
      )
    end
  end

  def linked_job_role(role)
    landing_page_link_or_text({ job_roles: [role] }, role)
  end

  def linked_ect_status(vacancy)
    return unless vacancy.job_roles.include?("teacher") && vacancy.ect_suitable?

    landing_page_link_or_text({ ect_statuses: [vacancy.ect_status] }, vacancy.ect_status.humanize)
  end
end
