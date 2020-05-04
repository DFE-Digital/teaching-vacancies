module VacanciesHelper
  WORD_EXCEPTIONS = ['and', 'the', 'of', 'upon'].freeze

  def job_role_options
    Vacancy::JOB_ROLE_OPTIONS
  end

  def working_pattern_options
    Vacancy::WORKING_PATTERN_OPTIONS.map do |key, _value|
      [Vacancy.human_attribute_name("working_patterns.#{key}"), key]
    end
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
      radii << ["#{radius} miles", radius]
    end
  end

  # rubocop:disable Rails/HelperInstanceVariable:
  def subject_options
    @subject_options ||= Subject.all.as_json.map { |subject| OpenStruct.new(id: subject['id'], name: subject['name']) }
    @subject_options.unshift(OpenStruct.new(id: nil, name: ''))
  end
  # rubocop:enable Rails/HelperInstanceVariable:

  def format_location_name(location)
    uncapitalize_words(location.titleize)
  end

  def uncapitalize_words(location_name)
    array = location_name.split(' ')
    array.map! { |word| WORD_EXCEPTIONS.include?(word.downcase) ? word.downcase : word }
    array.join(' ')
  end

  def location_category_content?(search)
    search.location_category_search? && search.only_active_to_hash.one?
  end

  def new_sections(vacancy)
    sections = []
    sections << 'job_role' unless vacancy.job_roles&.any?
    sections << 'supporting_documents' unless vacancy.supporting_documents
    sections
  end

  def page_title_prefix(vacancy, form_object, page_heading)
    if vacancy.published?
      "#{form_object.errors.present? ?
        'Error: ' : ''}Edit the #{page_heading}"
    else
      "#{form_object.errors.present? ?
        'Error: ' : ''}#{page_heading} — #{t('jobs.create_a_job', school: current_school.name)}"
    end
  end
end
