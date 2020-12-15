module VacanciesHelper
  include VacanciesOptionsHelper
  include AddressHelper

  WORD_EXCEPTIONS = %w[and the of upon].freeze

  def format_location_name(location)
    uncapitalize_words(location.titleize)
  end

  def uncapitalize_words(location_name)
    array = location_name.split(" ")
    array.map! { |word| WORD_EXCEPTIONS.include?(word.downcase) ? word.downcase : word }
    array.join(" ")
  end

  def new_attributes(vacancy)
    attributes = {}
    attributes[:supporting_documents] = t("jobs.supporting_documents") unless vacancy.supporting_documents
    attributes[:contact_number] = t("jobs.contact_number") unless vacancy.contact_number
    attributes
  end

  def page_title_prefix(vacancy, form_object, page_heading)
    if %w[create review].include?(vacancy.state)
      "#{form_object.errors.present? ? 'Error: ' : ''}#{page_heading} — #{t('jobs.create_a_job_title', organisation: current_organisation.name)}"
    else
      "#{form_object.errors.present? ? 'Error: ' : ''}Edit the #{page_heading}"
    end
  end

  def review_page_title_prefix(vacancy, organisation = current_organisation)
    page_title = t("jobs.review_page_title", organisation: organisation.name)
    "#{vacancy.errors.present? ? 'Error: ' : ''}#{page_title}"
  end

  def review_heading(vacancy)
    return t("jobs.copy_review_heading") if vacancy.state == "copy"

    t("jobs.review_heading")
  end

  def hidden_state_field_value(vacancy, copy = false)
    return "copy" if copy
    return "edit_published" if vacancy.published?
    return vacancy.state if %w[copy review edit].include?(vacancy.state)

    "create"
  end

  def back_to_manage_jobs_link(vacancy)
    state = if vacancy.listed?
              "published"
            elsif vacancy.published? && vacancy.expires_at.future?
              "pending"
            elsif vacancy.published? && vacancy.expires_at.past?
              "expired"
            else
              "draft"
            end
    jobs_with_type_organisation_path(state)
  end

  def expiry_date_and_time(vacancy)
    format_date(vacancy.expires_on) + " at " + vacancy.expires_at.strftime("%-l:%M %P")
  end

  def vacancy_or_organisation_description(vacancy)
    vacancy.about_school.presence || vacancy.parent_organisation.description.presence
  end

  def vacancy_about_school_label_organisation(vacancy)
    vacancy.organisations.many? ? "the schools" : vacancy.parent_organisation.name
  end

  def vacancy_about_school_hint_text(vacancy)
    if vacancy.organisations.many?
      return t("helpers.hint.job_summary_form.about_schools", organisation_type: organisation_type_basic(vacancy.parent_organisation))
    end

    t("helpers.hint.job_summary_form.about_organisation", organisation_type: organisation_type_basic(vacancy.parent_organisation).capitalize)
  end

  def vacancy_about_school_value(vacancy)
    return "" if vacancy.organisations.many?

    vacancy_or_organisation_description(vacancy)
  end

  def vacancy_job_location(vacancy)
    organisation = vacancy.parent_organisation
    return "#{t('publishers.organisations.readable_job_location.at_multiple_schools')}, #{organisation.name}" if
      vacancy.job_location == "at_multiple_schools"

    address_join([organisation.name, organisation.town, organisation.county])
  end

  def vacancy_job_location_heading(vacancy)
    return t("school_groups.job_location_heading.#{vacancy.job_location}") unless vacancy.job_location == "at_multiple_schools"

    t("school_groups.job_location_heading.at_multiple_schools", organisation_type: organisation_type_basic(vacancy.parent_organisation))
  end

  def vacancy_school_visits_hint(vacancy)
    organisation = organisation_type_basic(vacancy.parent_organisation).tr(" ", "_")
    t("helpers.hint.applying_for_the_job_form.#{organisation}_visits")
  end
end
