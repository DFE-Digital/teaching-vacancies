module VacanciesHelper
  SALARY_OPTIONS = {
    '£20,000' => 20000,
    '£30,000' => 30000,
    '£40,000' => 40000,
    '£50,000' => 50000,
    '£60,000' => 60000,
    '£70,000' => 70000
  }.freeze

  WORD_EXCEPTIONS = ['and', 'the', 'of', 'upon'].freeze

  def job_role_options
    Vacancy::JOB_ROLE_OPTIONS
  end

  def working_pattern_options
    Vacancy::WORKING_PATTERN_OPTIONS.map do |key, _value|
      [Vacancy.human_attribute_name("working_patterns.#{key}"), key]
    end
  end

  def school_phase_options
    School.phases.keys.map { |key| [key.humanize, key] }
  end

  def listed_elsewhere_options
    Vacancy.listed_elsewheres.keys.map { |k| [t("jobs.feedback.listed_elsewhere.#{k}"), k] }
  end

  def hired_status_options
    Vacancy.hired_statuses.keys.map { |k| [t("jobs.feedback.hired_status.#{k}"), k] }
  end

  def job_sorting_options
    [
      [t('jobs.sort_by_most_recent'), :sort_by_most_recent],
      [t('jobs.sort_by_most_ancient'), :sort_by_most_ancient],
      [t('jobs.sort_by_earliest_closing_date'), :sort_by_earliest_closing_date],
      [t('jobs.sort_by_furthest_closing_date'), :sort_by_furthest_closing_date]
    ]
  end

  def selected_sorting_method(sort:)
    return publish_on_selected_sorting_method(sort) if sort.column == 'publish_on'
    return expires_on_selected_sorting_method(sort) if sort.column == 'expires_on'
  end

  def publish_on_selected_sorting_method(sort)
    return :sort_by_most_ancient if sort.order == 'asc'
    return :sort_by_most_recent if sort.order == 'desc'
  end

  def expires_on_selected_sorting_method(sort)
    return :sort_by_earliest_closing_date if sort.order == 'asc'
    return :sort_by_furthest_closing_date if sort.order == 'desc'
  end

  def vacancy_params_whitelist
    %i[sort_column sort_order page].concat(VacancyFilters::AVAILABLE_FILTERS)
  end

  def vacancy_params(overwrite = {})
    params.merge(overwrite).permit(vacancy_params_whitelist)
  end

  def radius_filter_options
    [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100, 200].inject([]) do |radii, radius|
      radii << ["Within #{radius} miles", radius]
    end
  end

  # rubocop:disable Rails/HelperInstanceVariable:
  def subject_options
    @subject_options ||= Subject.all.as_json.map { |subject| OpenStruct.new(id: subject['id'], name: subject['name']) }
    @subject_options.unshift(OpenStruct.new(id: nil, name: ''))
  end
  # rubocop:enable Rails/HelperInstanceVariable:

  def phase_checked?(phase)
    return false if phases.blank?

    phases.include?(phase)
  end

  def working_pattern_checked?(working_pattern)
    return false if working_patterns.blank?

    working_patterns.include?(working_pattern)
  end

  def nqt_suitable_checked?(newly_qualified_teacher)
    newly_qualified_teacher == 'true'
  end

  def format_location_name(location)
    uncapitalize_words(location.titleize)
  end

  def uncapitalize_words(location_name)
    array = location_name.split(' ')
    array.map! { |word| WORD_EXCEPTIONS.include?(word.downcase) ? word.downcase : word }
    array.join(' ')
  end

  def location_category_content?(filters)
    filters.location_category_search? && filters.only_active_to_hash.one?
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
