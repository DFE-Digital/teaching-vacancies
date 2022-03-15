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
      next unless location && LocationLandingPage.exists?(location)

      govuk_link_to(LocationLandingPage[location].name, location_landing_page_path(LocationLandingPage[location].location))
    end
  end

  def linked_job_roles(vacancy)
    tag.ul class: "govuk-list" do
      safe_join(
        vacancy.job_roles.map do |job_role|
          tag.li landing_page_link_or_text({ job_roles: [job_role] }, job_role.capitalize)
        end,
      )
    end
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
            landing_page_link_or_text({ working_patterns: [working_pattern] }, working_pattern.capitalize)
          }.join(", ").html_safe
        end,
        tag.li { tag.span(vacancy.working_patterns_details) },
      ]
    end
  end

  def linked_school_phases(school)
    safe_join(
      (school.readable_phases || []).map do |phase|
        landing_page_link_or_text({ phases: [phase] }, phase.capitalize)
      end, ", "
    )
  end
end
