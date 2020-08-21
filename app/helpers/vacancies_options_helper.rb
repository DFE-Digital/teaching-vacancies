module VacanciesOptionsHelper
  def hired_status_options
    Vacancy.hired_statuses.keys.map { |k| [t("jobs.feedback.hired_status.#{k}"), k] }
  end

  def job_location_options
    Vacancy::JOB_LOCATION_OPTIONS.map { |key, _value|
      [I18n.t("helpers.fieldset.job_location_form.job_location_options.#{key}"), key] if
        MultiSchoolJobsFeature.enabled? || key != :at_multiple_schools
    }.reject(&:blank?)
  end

  def job_role_options
    Vacancy::JOB_ROLE_OPTIONS.except(:nqt_suitable).map do |key, _value|
      [I18n.t("jobs.job_role_options.#{key}"), key]
    end
  end

  def job_sorting_options
    Vacancy::JOB_SORTING_OPTIONS
  end

  def listed_elsewhere_options
    Vacancy.listed_elsewheres.keys.map { |k| [t("jobs.feedback.listed_elsewhere.#{k}"), k] }
  end

  def radius_filter_options
    [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100, 200].inject([]) do |radii, radius|
      radii << [I18n.t('jobs.filters.number_of_miles', count: radius), radius]
    end
  end

  def subject_options
    SUBJECT_OPTIONS
  end

  def working_pattern_options
    Vacancy::WORKING_PATTERN_OPTIONS.keys.map do |key|
      [Vacancy.human_attribute_name("working_patterns.#{key}"), key.to_s]
    end
  end
end
