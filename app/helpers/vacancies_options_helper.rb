module VacanciesOptionsHelper
  RADIUS_OPTIONS = [0, 1, 5, 10, 25, 50, 100, 200].freeze

  def hired_status_options
    Vacancy.hired_statuses.keys.map { |k| [t("jobs.feedback.hired_status.#{k}"), k] }.unshift(["--", ""])
  end

  def listed_elsewhere_options
    Vacancy.listed_elsewheres.keys.map { |k| [t("jobs.feedback.listed_elsewhere.#{k}"), k] }.unshift(["--", ""])
  end

  def radius_filter_options
    RADIUS_OPTIONS.inject([]) do |radii, radius|
      radii << [t("jobs.search.number_of_miles", count: radius), radius]
    end
  end

  def candidate_hired_from_options
    Vacancy.candidate_hired_froms.keys
      .map { |k| [t("helpers.options.publishers_job_listing_end_listing_form.candidate_hired_from.#{k}"), k] }
      .unshift(["Select a service or application method", ""])
  end
end
