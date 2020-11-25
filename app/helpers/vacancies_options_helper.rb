module VacanciesOptionsHelper
  def hired_status_options
    Vacancy.hired_statuses.keys.map { |k| [t("jobs.feedback.hired_status.#{k}"), k] }
  end

  def job_location_options(organisation)
    mapped_job_location_options(organisation)
      .delete_if { |_k, v| organisation.group_type == "local_authority" && v == "central_office" }
      .reject(&:blank?)
  end

  def job_role_options
    Vacancy.job_roles.except("nqt_suitable").keys.map do |option|
      [I18n.t("jobs.job_role_options.#{option}"), option]
    end
  end

  def job_sorting_options
    Vacancy::JOB_SORTING_OPTIONS
  end

  def listed_elsewhere_options
    Vacancy.listed_elsewheres.keys.map { |k| [t("jobs.feedback.listed_elsewhere.#{k}"), k] }
  end

  def mapped_job_location_options(organisation)
    Vacancy.job_locations.keys.map do |job_location|
      [I18n.t("helpers.options.job_location_form.job_location.#{job_location}",
              organisation_type: organisation_type_basic(organisation)),
       job_location]
    end
  end

  def radius_filter_options
    Search::SuggestionsBuilder::RADIUS_OPTIONS.inject([]) do |radii, radius|
      radii << [I18n.t("jobs.filters.number_of_miles", count: radius), radius]
    end
  end

  def subject_options
    SUBJECT_OPTIONS
  end

  def working_pattern_options
    Vacancy.working_patterns.keys.map do |key|
      [Vacancy.human_attribute_name("working_patterns.#{key}"), key]
    end
  end
end
