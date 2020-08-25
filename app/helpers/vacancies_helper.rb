module VacanciesHelper
  include VacanciesOptionsHelper

  WORD_EXCEPTIONS = ['and', 'the', 'of', 'upon'].freeze

  def format_location_name(location)
    uncapitalize_words(location.titleize)
  end

  def uncapitalize_words(location_name)
    array = location_name.split(' ')
    array.map! { |word| WORD_EXCEPTIONS.include?(word.downcase) ? word.downcase : word }
    array.join(' ')
  end

  def new_sections(vacancy)
    sections = []
    sections << 'job_details' if missing_subjects?(vacancy)
    sections << 'supporting_documents' unless vacancy.supporting_documents
    sections
  end

  def page_title_prefix(vacancy, form_object, page_heading)
    if %w(create review).include?(vacancy.state)
      "#{form_object.errors.present? ?
        'Error: ' : ''}#{page_heading} — #{t('jobs.create_a_job_title', organisation: current_organisation.name)}"
    else
      "#{form_object.errors.present? ?
        'Error: ' : ''}Edit the #{page_heading}"
    end
  end

  def review_page_title_prefix(vacancy, organisation = current_organisation)
    page_title = I18n.t('jobs.review_page_title', organisation: organisation.name)
    "#{vacancy.errors.present? ? 'Error: ' : ''}#{page_title}"
  end

  def review_heading(vacancy)
    return I18n.t('jobs.copy_review_heading') if vacancy.state == 'copy'
    I18n.t('jobs.review_heading')
  end

  def page_title(vacancy)
    return I18n.t('jobs.copy_job_title', job_title: vacancy.job_title) if vacancy.state == 'copy'
    return I18n.t('jobs.create_a_job_title', organisation: organisation_from_job_location(vacancy)) if
      %w(create review).include?(vacancy.state)
    I18n.t('jobs.edit_job_title', job_title: vacancy.job_title)
  end

  def organisation_from_job_location(vacancy)
    vacancy.job_location == 'at_multiple_schools' ? 'multiple schools' : vacancy.organisation_name
  end

  def page_title_no_vacancy
    organisation_for_title =
      if session[:vacancy_attributes] && session[:vacancy_attributes]['job_location'] == 'at_one_school'
        session[:vacancy_attributes]['readable_job_location']
      elsif session[:vacancy_attributes] && session[:vacancy_attributes]['job_location'] == 'at_multiple_schools'
        'multiple schools'
      else
        current_organisation.name
      end

    organisation_for_title ?
      I18n.t('jobs.create_a_job_title', organisation: organisation_for_title) : I18n.t('jobs.create_a_job_title_no_org')
  end

  def missing_subjects?(vacancy)
    legacy_subjects = [vacancy.subject,
                       vacancy.first_supporting_subject,
                       vacancy.second_supporting_subject].reject(&:blank?)
    legacy_subjects.any? && legacy_subjects.count != vacancy.subjects&.count
  end

  def hidden_state_field_value(vacancy, copy = false)
    return 'copy' if copy
    return 'edit_published' if vacancy&.published?
    return vacancy&.state if %w(copy review edit).include?(vacancy&.state)
    'create'
  end

  def back_to_manage_jobs_link(vacancy)
    if vacancy.listed?
      state = 'published'
    elsif vacancy.published? && vacancy.expiry_time.future?
      state = 'pending'
    elsif vacancy.published? && vacancy.expiry_time.past?
      state = 'expired'
    else
      state = 'draft'
    end
    jobs_with_type_organisation_path(state)
  end

  def expiry_date_and_time(vacancy)
    format_date(vacancy.expires_on) + ' at ' + vacancy.expiry_time.strftime('%-l:%M %P')
  end

  def vacancy_or_organisation_description(vacancy)
    vacancy.about_school.presence || vacancy.organisation.description.presence
  end
end
