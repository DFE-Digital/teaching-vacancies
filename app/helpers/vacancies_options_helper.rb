module VacanciesOptionsHelper
  RADIUS_OPTIONS = [0, 1, 5, 10, 15, 20, 25, 50, 100, 200].freeze

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
end
