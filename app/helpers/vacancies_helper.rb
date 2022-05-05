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

  def salary_label(vacancy)
    vacancy.actual_salary? ? t("jobs.annual_salary") : t("jobs.salary")
  end

  def salary_value(vacancy)
    safe_join [vacancy.salary, actual_salary(vacancy)]
  end

  def actual_salary(vacancy)
    return unless vacancy.actual_salary?

    [
      tag.div(t("jobs.actual_salary"), class: "govuk-hint govuk-!-margin-bottom-0 govuk-!-margin-top-1 govuk-!-font-size-16"),
      vacancy.actual_salary,
    ]
  end

  def organisation_type_label(vacancy)
    vacancy.central_office? ? t("jobs.trust_type") : t("jobs.school_type")
  end

  def organisation_type_value(vacancy)
    return organisation_type(vacancy.organisation) unless vacancy.at_multiple_schools?

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

  def vacancy_job_location(vacancy)
    organisation = vacancy.organisation
    return "#{t('publishers.organisations.readable_job_location.at_multiple_schools')}, #{organisation.name}" if vacancy.at_multiple_schools?

    address_join([organisation.name, organisation.town, organisation.county])
  end

  def vacancy_full_job_location(vacancy)
    organisation = vacancy.organisation
    return "#{t('publishers.organisations.readable_job_location.at_multiple_schools')}, #{organisation.name}" if vacancy.at_multiple_schools?

    address_join([organisation.name, organisation.town, organisation.county, organisation.postcode])
  end

  def vacancy_job_location_heading(vacancy)
    return t("organisations.job_location_heading.#{vacancy.job_location}") unless vacancy.at_multiple_schools?

    t("organisations.job_location_heading.at_multiple_schools", organisation_type: organisation_type_basic(vacancy.organisation))
  end

  def vacancy_listing_page_title_prefix(vacancy)
    "#{vacancy.job_title} - #{vacancy.at_one_school? ? vacancy.organisation.town : vacancy.organisation_name}"
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

  def vacancy_activity_log_item(attribute, new_value, organisation_type)
    new_value.map! { |value| Vacancy.array_enums[attribute.to_sym].key(value).humanize } if attribute.to_sym.in?(Vacancy.array_enums)

    case attribute
    when "job_roles", "key_stages", "subjects", "working_patterns"
      t("publishers.activity_log.#{attribute}", new_value: new_value.to_sentence, count: new_value.count)
    when "about_school", "job_advert"
      t("publishers.activity_log.#{attribute}", organisation_type: organisation_type)
    when "expires_at", "starts_on"
      t("publishers.activity_log.#{attribute}", new_value: (new_value.nil? ? t("jobs.starts_asap") : format_date(new_value.to_date)))
    when "school_visits"
      t("publishers.activity_log.school_visits", organisation_type: organisation_type.capitalize, new_value: new_value)
    else
      t("publishers.activity_log.#{attribute}", new_value: new_value.humanize)
    end
  end

  def vacancy_select_a_job_to_copy_hint(vacancy)
    safe_join [tag.div(t(".closing_date", date: vacancy.expires_at)), tag.div(vacancy.organisation_name, class: "govuk-!-margin-top-1")]
  end

  def working_patterns(vacancy)
    vacancy.working_patterns.map { |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ").capitalize
  end
end
