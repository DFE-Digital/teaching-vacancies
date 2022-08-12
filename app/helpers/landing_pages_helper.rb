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

  def linked_job_role_and_ect_status(vacancy)
    tag.ul class: "govuk-list" do
      safe_join [
        tag.li(linked_job_role(vacancy)),
        tag.li(linked_ect_status(vacancy)),
      ]
    end
  end

  def linked_job_role(vacancy)
    landing_page_link_or_text({ job_roles: [vacancy.job_role] }, vacancy.job_role&.humanize)
  end

  def linked_ect_status(vacancy)
    return unless vacancy.teacher? && vacancy.ect_suitable?

    landing_page_link_or_text({ ect_statuses: [vacancy.ect_status] }, vacancy.ect_status.humanize)
  end

  def linked_subjects(vacancy)
    vacancy.subjects.map { |subject|
      landing_page_link_or_text({ subjects: [subject] }, subject, match: :partial)
    }.join(", ").html_safe
  end

  def linked_working_patterns(vacancy)
    tag.ul class: "govuk-list" do
      safe_join [
        tag.li do
          vacancy.working_patterns.map { |working_pattern|
            landing_page_link_or_text({ working_patterns: [working_pattern] }, working_pattern&.capitalize)
          }.join(", ").html_safe
        end,
        tag.li { tag.span(vacancy.working_patterns_details) },
      ]
    end
  end

  def linked_school_phase(school)
    landing_page_link_or_text({ phases: [school.readable_phase] }, school.readable_phase&.capitalize)
  end
end
