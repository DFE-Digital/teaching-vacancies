class Jobseekers::SavedJobSort < RecordSort
  def initialize
    @column = options.first.column
    @order = options.first.order
  end

  def options
    [
      SortOption.new("created_at", "desc", I18n.t("jobs.sort_by.created_at.descending.saved_job")),
      SortOption.new("vacancies.expires_at", "asc", I18n.t("jobs.sort_by.expires_at.ascending.saved_job")),
      SortOption.new("vacancies.job_title", "asc", I18n.t("jobs.sort_by.job_title.ascending")),
      SortOption.new("vacancies.readable_job_location", "asc", I18n.t("jobs.sort_by.location.ascending")),
    ]
  end
end
