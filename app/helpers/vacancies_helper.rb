module VacanciesHelper
  include VacanciesOptionsHelper
  include AddressHelper

  WORD_EXCEPTIONS = %w[and the of upon].freeze

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

  def actual_salary(vacancy)
    return unless vacancy.actual_salary?

    [
      tag.div(t("jobs.actual_salary"), class: "govuk-hint govuk-!-margin-bottom-0 govuk-!-margin-top-1 govuk-!-font-size-16"),
      vacancy.actual_salary,
    ]
  end

  def pay_scale(vacancy)
    return unless vacancy.pay_scale?

    [
      tag.div(t("jobs.pay_scale"), class: "govuk-hint govuk-!-margin-bottom-0 govuk-!-margin-top-1 govuk-!-font-size-16"),
      vacancy.pay_scale,
    ]
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

  def vacancy_about_school_label_organisation(vacancy)
    vacancy.organisations.many? ? "the schools" : vacancy.organisation_name
  end

  def vacancy_about_school_hint_text(vacancy)
    return t("helpers.hint.publishers_job_listing_job_summary_form.about_schools", organisation_type: organisation_type_basic(vacancy.organisation)) if vacancy.organisations.many?

    t("helpers.hint.publishers_job_listing_job_summary_form.about_organisation", organisation_type: organisation_type_basic(vacancy.organisation).capitalize)
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

  def vacancy_job_location_heading(vacancy)
    if vacancy.central_office?
      t("organisations.job_location_heading.central_office")
    elsif vacancy.organisations.many?
      t("organisations.job_location_heading.at_multiple_locations", organisation_type: organisation_type_basic(vacancy.organisation))
    else
      t("organisations.job_location_heading.at_one_location")
    end
  end

  def vacancy_job_location(vacancy)
    organisation = vacancy.organisation
    return "#{t('organisations.job_location_summary.at_multiple_locations')}, #{organisation.name}" if vacancy.organisations.many?

    address_join([organisation.name, organisation.town, organisation.county])
  end

  def vacancy_full_job_location(vacancy)
    organisation = vacancy.organisation
    return "#{t('organisations.job_location_summary.at_multiple_locations')}, #{govuk_link_to(organisation.name, organisation_landing_page_path(organisation))}".html_safe if vacancy.organisations.many?

    address_join([govuk_link_to(organisation.name, organisation_landing_page_path(organisation)), organisation.town, organisation.county, organisation.postcode]).html_safe
  end

  def vacancy_listing_page_title_prefix(vacancy)
    "#{vacancy.job_title} - #{vacancy.organisation_name}"
  end

  def vacancy_school_visits_hint(vacancy)
    organisation = organisation_type_basic(vacancy.organisation).tr(" ", "_")
    t("helpers.hint.publishers_job_listing_applying_for_the_job_details_form.#{organisation}_visits")
  end

  def vacancy_step_completed?(vacancy, step)
    vacancy.completed_steps.include?(step.to_s)
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

  def referrer_organisation_slug(referrer)
    organisation_slug = referrer.path.gsub("/organisations/", "")

    return unless referrer.host == request.host && OrganisationLandingPage.exists?(organisation_slug)

    organisation_slug
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

  def vacancy_select_a_job_to_copy_hint(vacancy)
    safe_join [tag.div(t(".closing_date", date: vacancy.expires_at)), tag.div(vacancy.organisation_name, class: "govuk-!-margin-top-1")]
  end

  def vacancy_working_patterns(vacancy)
    # TODO: Working Patterns: Remove call to vacancy_working_patterns_summary once all vacancies with legacy working patterns & working_pattern_details have expired
    return vacancy_working_patterns_summary(vacancy) unless vacancy.full_time_details? || vacancy.part_time_details?

    safe_join [
      (tag.div { t("jobs.full_time_details", details: vacancy.full_time_details) } if vacancy.full_time_details?),
      (tag.div { t("jobs.part_time_details", details: vacancy.part_time_details) } if vacancy.part_time_details?),
    ]
  end

  private

  def vacancy_working_patterns_summary(vacancy)
    vacancy.working_patterns.map { |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ").capitalize
  end
end
