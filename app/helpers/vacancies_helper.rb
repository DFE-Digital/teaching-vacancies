module VacanciesHelper
  WORD_EXCEPTIONS = ['and', 'the', 'of', 'upon'].freeze

  def job_role_options
    Vacancy::JOB_ROLE_OPTIONS.except(:nqt_suitable).map { |key, _value| [I18n.t("jobs.job_role_options.#{key}"), key] }
  end

  def working_pattern_options
    Vacancy::WORKING_PATTERN_OPTIONS.keys.map do |key|
      [Vacancy.human_attribute_name("working_patterns.#{key}"), key.to_s]
    end
  end

  def subject_options
    SUBJECT_OPTIONS
  end

  def listed_elsewhere_options
    Vacancy.listed_elsewheres.keys.map { |k| [t("jobs.feedback.listed_elsewhere.#{k}"), k] }
  end

  def hired_status_options
    Vacancy.hired_statuses.keys.map { |k| [t("jobs.feedback.hired_status.#{k}"), k] }
  end

  def job_sorting_options
    Vacancy::JOB_SORTING_OPTIONS
  end

  def radius_filter_options
    [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100, 200].inject([]) do |radii, radius|
      radii << [I18n.t('jobs.filters.number_of_miles', count: radius), radius]
    end
  end

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
    return I18n.t('jobs.create_a_job_title', organisation: vacancy.school_or_school_group&.name.presence || '') if
      %w(create review).include?(vacancy.state)
    I18n.t('jobs.edit_job_title', job_title: vacancy.job_title)
  end

  def page_title_no_vacancy
    return I18n.t('jobs.create_a_job_title', organisation: session[:vacancy_attributes]['readable_job_location']) if
      session[:vacancy_attributes].present? && session[:vacancy_attributes]['school_id'].present? &&
      session[:vacancy_attributes]['job_location'] == 'at_one_school'
    I18n.t('jobs.create_a_job_title', organisation: current_organisation.name)
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
    vacancy.about_school.presence || vacancy.school_or_school_group.description.presence
  end

  def service_start_page_filters_hash
    { removeButtons: false,
      totalCount: job_role_options.size,
      has_submit_button: false,
      items: [
        { options: job_role_options,
          title: 'Job roles',
          search: false,
          attribute: :job_roles,
          value_method: :last,
          text_method: :first,
          small: true }
        ]
      }
  end
end
