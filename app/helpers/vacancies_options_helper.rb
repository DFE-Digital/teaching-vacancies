module VacanciesOptionsHelper
  def hired_status_options
    Vacancy.hired_statuses.keys.map { |k| [t("jobs.feedback.hired_status.#{k}"), k] }.unshift(["--", ""])
  end

  def listed_elsewhere_options
    Vacancy.listed_elsewheres.keys.map { |k| [t("jobs.feedback.listed_elsewhere.#{k}"), k] }.unshift(["--", ""])
  end

  def job_location_options(organisation)
    mapped_job_location_options(organisation)
      .delete_if { |_k, v| organisation.group_type == "local_authority" && v == "central_office" }
      .reject(&:blank?)
  end

  def mapped_job_location_options(organisation)
    Vacancy.job_locations.keys.map do |job_location|
      [t("helpers.options.publishers_job_listing_job_location_form.job_location.#{job_location}", organisation_type: organisation_type_basic(organisation)), job_location]
    end
  end

  def radius_filter_options
    Search::RadiusSuggestionsBuilder::RADIUS_OPTIONS.inject([]) do |radii, radius|
      radii << [t("jobs.filters.number_of_miles", count: radius), radius]
    end
  end

  def candidate_hired_from_options
    Vacancy.candidate_hired_froms.keys
      .map { |k| [t("helpers.options.publishers_job_listing_end_listing_form.candidate_hired_from.#{k}"), k] }
      .unshift(["Select a service or application method", ""])
  end
end
