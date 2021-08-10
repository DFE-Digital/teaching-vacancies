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

  def review_page_title_prefix(vacancy, organisation = current_organisation)
    page_title = t("jobs.review_page_title", organisation: organisation.name)
    "#{vacancy.errors.present? ? 'Error: ' : ''}#{page_title}"
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

  def vacancy_school_visits_hint(vacancy)
    organisation = organisation_type_basic(vacancy.parent_organisation).tr(" ", "_")
    t("helpers.hint.publishers_job_listing_applying_for_the_job_form.#{organisation}_visits")
  end

  def vacancy_step_completed?(vacancy, step_number)
    return false if vacancy.completed_step.nil?

    step_number <= vacancy.completed_step
  end

  def steps_to_display(steps, steps_adjust)
    steps_to_remove = current_organisation.is_a?(School) ? %i[supporting_documents review] : %i[supporting_documents schools review]

    steps.transform_values { |step_details| step_details[:number] - steps_adjust }
         .except!(*steps_to_remove)
         .reject { |_, step_number| step_number.zero? }
  end

  def total_steps(steps)
    steps.values.map { |step| step[:number] }.max - steps_adjust
  end
end
