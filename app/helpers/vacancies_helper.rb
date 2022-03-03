module VacanciesHelper
  include VacanciesOptionsHelper
  include AddressHelper

  WORD_EXCEPTIONS = %w[and the of upon].freeze

  def format_location_name(location)
    uncapitalize_words(location.titleize)
  end

  def uncapitalize_words(location_name)
    array = location_name.split
    array.map! { |word| WORD_EXCEPTIONS.include?(word.downcase) ? word.downcase : word }
    array.join(" ")
  end

  def page_title_prefix(vacancy, form_object, page_heading)
    if vacancy.published?
      "#{form_object.errors.present? ? 'Error: ' : ''}Edit the #{page_heading} for #{vacancy.job_title}"
    else
      "#{form_object.errors.present? ? 'Error: ' : ''}#{page_heading} — #{t('jobs.create_a_job_title', organisation: current_organisation.name)}"
    end
  end

  def review_page_title_prefix(vacancy, organisation: current_organisation, show_errors: true)
    page_title = t("jobs.review_page_title", organisation: organisation.name)
    "#{'Error: ' if vacancy.errors.present? && show_errors}#{page_title}"
  end

  def vacancy_or_organisation_description(vacancy)
    vacancy.about_school.presence || vacancy.parent_organisation.description.presence
  end

  def vacancy_about_school_label_organisation(vacancy)
    vacancy.organisations.many? ? "the schools" : vacancy.parent_organisation.name
  end

  def vacancy_about_school_hint_text(vacancy)
    return t("helpers.hint.publishers_job_listing_job_summary_form.about_schools", organisation_type: organisation_type_basic(vacancy.parent_organisation)) if vacancy.organisations.many?

    t("helpers.hint.publishers_job_listing_job_summary_form.about_organisation", organisation_type: organisation_type_basic(vacancy.parent_organisation).capitalize)
  end

  def vacancy_about_school_value(vacancy)
    return "" if vacancy.organisations.many?

    vacancy_or_organisation_description(vacancy)
  end

  def vacancy_job_location(vacancy)
    organisation = vacancy.parent_organisation
    return "#{t('publishers.organisations.readable_job_location.at_multiple_schools')}, #{organisation.name}" if vacancy.at_multiple_schools?

    address_join([organisation.name, organisation.town, organisation.county])
  end

  def vacancy_full_job_location(vacancy)
    organisation = vacancy.parent_organisation
    return "#{t('publishers.organisations.readable_job_location.at_multiple_schools')}, #{organisation.name}" if vacancy.at_multiple_schools?

    address_join([organisation.name, organisation.town, organisation.county, organisation.postcode])
  end

  def vacancy_job_location_heading(vacancy)
    return t("school_groups.job_location_heading.#{vacancy.job_location}") unless vacancy.at_multiple_schools?

    t("school_groups.job_location_heading.at_multiple_schools", organisation_type: organisation_type_basic(vacancy.parent_organisation))
  end

  def vacancy_listing_page_title_prefix(vacancy)
    "#{vacancy.job_title} - #{vacancy.at_one_school? ? vacancy.parent_organisation.town : vacancy.parent_organisation.name}"
  end

  def vacancy_school_visits_hint(vacancy)
    organisation = organisation_type_basic(vacancy.parent_organisation).tr(" ", "_")
    t("helpers.hint.publishers_job_listing_applying_for_the_job_details_form.#{organisation}_visits")
  end

  def vacancy_step_completed?(vacancy, step)
    vacancy.completed_steps.include?(step.to_s)
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

  def linked_working_patterns(vacancy)
    tag.ul class: "govuk-list" do
      safe_join [
        tag.li do
          vacancy.model_working_patterns.map { |working_pattern|
            landing_page_link_or_text({ working_patterns: [working_pattern] }, working_pattern.capitalize)
          }.join(", ").html_safe
        end,
        tag.li { tag.span(vacancy.working_patterns_details) },
      ]
    end
  end

  def map_links(vacancy)
    vacancy.organisations.map do |organisation|
      { text: "#{organisation.name}, #{full_address(organisation)}", url: organisation_url(organisation), id: organisation.id }
    end
  end

  # Determines a set of breadcrumbs for a vacancy view page based on whether the user has arrived
  # there from a search results page (take them back to search results) or somewhere else (take
  # them to the appropriate landing page, or if all else fails, the "all jobs" page)
  def vacancy_breadcrumbs(vacancy)
    referrer = URI(request.referrer || "")
    referred_from_jobs_path = referrer.host == request.host && referrer.path == jobs_path

    parent_breadcrumb = if referred_from_jobs_path
                          { t("breadcrumbs.jobs") => request.referrer }
                        elsif (lp = LandingPage.matching(job_roles: [vacancy.main_job_role]))
                          { lp.title => landing_page_path(lp.slug) }
                        else
                          { t("breadcrumbs.jobs") => jobs_path }
                        end

    {
      "#{t("breadcrumbs.home")}": root_path,
      **parent_breadcrumb,
      "#{vacancy.job_title}": "",
    }
  end
end
