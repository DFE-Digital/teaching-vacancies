module VacanciesHelper
  include VacanciesOptionsHelper
  include AddressHelper
  include LinksHelper

  WORD_EXCEPTIONS = %w[and the of upon].freeze

  def humanize_array(items)
    items.map(&:humanize).join(", ")
  end

  def location_formatter(items)
    items.map { |value|
      "#{value['location']} (#{t('jobs.search.number_of_miles', count: value['radius'].to_i)})"
    }.join(" ")
  end

  def page_title_prefix(step_process, form_object)
    page_heading = t("publishers.vacancies.steps.#{step_process.current_step}")
    create_or_edit = step_process.vacancy.published? ? "edit" : "create"
    section_number = step_process.current_step_group_number

    "#{form_object.errors.present? ? 'Error: ' : ''}#{page_heading} - #{t("publishers.vacancies.build.page_title.#{create_or_edit}", section_number: section_number)}"
  end

  def review_page_title_prefix(vacancy)
    heading = t("publishers.vacancies.review.heading", status: (vacancy.publish_on&.future? ? "schedule" : "publish"))
    t("publishers.vacancies.review.page_title", heading: heading)
  end

  def publishers_show_page_title_prefix(vacancy)
    t("publishers.vacancies.show.page_title", job_title: vacancy.job_title)
  end

  def organisation_type_label(vacancy)
    vacancy.central_office? ? t("jobs.trust_type") : t("jobs.school_type")
  end

  def organisation_type_value(vacancy)
    return organisation_type(vacancy.organisation) unless vacancy.organisations.many?

    safe_join(organisation_types(vacancy.organisations).map do |organisation_type|
      tag.div(organisation_type, class: "govuk-body-s govuk-!-margin-bottom-0")
    end)
  end

  def vacancy_or_organisation_description(vacancy)
    vacancy.about_school.presence || vacancy.organisation.description.presence
  end

  def vacancy_about_school_value(vacancy)
    return "" if vacancy.organisations.many?

    vacancy_or_organisation_description(vacancy)
  end

  def vacancy_job_location_summary(vacancy)
    return vacancy.organisation_name if vacancy.organisation.is_a?(School)

    if vacancy.organisations.many?
      t("organisations.job_location_summary.at_multiple_locations_with_count", count: vacancy.organisations.count)
    else
      t("organisations.job_location_summary.central_office")
    end
  end

  def vacancy_job_locations(vacancy)
    safe_join(
      vacancy.organisations.map do |organisation|
        tag.li("#{organisation.school? ? organisation.name : t('organisations.job_location_heading.central_office')}, #{full_address(organisation)}")
      end,
    )
  end

  def vacancy_job_location(vacancy)
    organisation = vacancy.organisation
    return "#{t('organisations.job_location_summary.at_multiple_locations')}, #{organisation.name}" if vacancy.organisations.many?

    address_join([organisation.name, organisation.town, organisation.county])
  end

  def local_authority_job_location_hint(current_publisher_preference)
    t("helpers.hint.publishers_job_listing_schools_form.edit_schools_html",
      link: govuk_link_to(t("helpers.hint.publishers_job_listing_schools_form.add_school"),
                          edit_publishers_publisher_preference_path(current_publisher_preference),
                          class: "govuk-link--no-visited-state"))
  end

  def vacancy_full_job_location(vacancy)
    organisation = vacancy.organisation
    return "#{t('organisations.job_location_summary.at_multiple_locations')}, #{organisation.name}" if vacancy.organisations.many?

    address_join([organisation.name, organisation.town, organisation.county, organisation.postcode])
  end

  def vacancy_listing_page_title_prefix(vacancy)
    "#{vacancy.job_title} - #{vacancy.organisation_name}"
  end

  # Determines a set of breadcrumbs for a vacancy view page based on whether the user has arrived
  # there from a search results page (take them back to search results) or somewhere else (take
  # them to the appropriate landing page, or if all else fails, the "all jobs" page)
  def vacancy_breadcrumbs(vacancy)
    referrer = URI(request.referrer || "")
    referred_from_jobs_path = referrer.host == request.host && referrer.path == jobs_path

    parent_breadcrumb = if (organisation_slug = referrer_organisation_slug(referrer))
                          landing_page = OrganisationLandingPage[organisation_slug]
                          { landing_page.name => organisation_landing_page_path(organisation_slug) }
                        elsif referred_from_jobs_path
                          { t("breadcrumbs.jobs") => request.referrer }
                        elsif (lp = LandingPage.matching(job_roles: [vacancy.job_role]))
                          { lp.title => landing_page_path(lp.slug) }
                        else
                          { t("breadcrumbs.jobs") => jobs_path }
                        end

    {
      "#{t("breadcrumbs.home")}": root_path,
      **parent_breadcrumb,
    }
  end

  def organisation_landing_page_breadcrumbs(organisation_slug)
    landing_page = OrganisationLandingPage[organisation_slug]
    {
      t("breadcrumbs.home") => root_path,
      landing_page.name => nil,
    }
  end

  def vacancy_activity_log_item(attribute, new_value, organisation_type)
    new_value.map! { |value| Vacancy.array_enums[attribute.to_sym].key(value).humanize } if attribute.to_sym.in?(Vacancy.array_enums)

    case attribute
    when "job_roles", "key_stages", "subjects", "working_patterns"
      t("publishers.activity_log.#{attribute}", new_value: new_value.to_sentence, count: new_value.count)
    when "about_school", "job_advert"
      t("publishers.activity_log.#{attribute}", organisation_type: organisation_type)
    when "expires_at", "starts_on", "earliest_start_date", "latest_start_date"
      new_value.nil? ? t("publishers.activity_log.#{attribute}.deleted") : t("publishers.activity_log.#{attribute}.changed", new_value: format_date(new_value.to_date))
    when "other_start_date_details"
      new_value.nil? ? t("publishers.activity_log.#{attribute}.deleted") : t("publishers.activity_log.#{attribute}.changed", new_value: new_value)
    when "school_visits"
      t("publishers.activity_log.school_visits", organisation_type: organisation_type.capitalize, new_value: new_value)
    else
      t("publishers.activity_log.#{attribute}", new_value: new_value.humanize)
    end
  end

  def vacancy_working_patterns(vacancy)
    # TODO: Working Patterns: Remove call to vacancy_working_patterns_summary once all vacancies with legacy working patterns & working_pattern_details have expired
    return vacancy_working_patterns_summary(vacancy) unless vacancy.full_time_details? || vacancy.part_time_details?

    safe_join [
      (tag.li { t("jobs.full_time_details", details: vacancy.full_time_details) } if vacancy.full_time_details?),
      (tag.li { t("jobs.part_time_details", details: vacancy.part_time_details) } if vacancy.part_time_details?),
    ]
  end

  def vacancy_how_to_apply_step(vacancy)
    case vacancy.receive_applications
    when "email"
      :application_form
    when "website"
      :application_link
    else
      :how_to_receive_applications
    end
  end

  private

  def referrer_organisation_slug(referrer)
    organisation_slug = referrer.path.gsub("/organisations/", "")

    return unless referrer.host == request.host && OrganisationLandingPage.exists?(organisation_slug)

    organisation_slug
  end

  def vacancy_working_patterns_summary(vacancy)
    vacancy.working_patterns.map { |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ").capitalize
  end
end
