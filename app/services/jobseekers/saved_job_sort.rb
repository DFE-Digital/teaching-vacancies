class Jobseekers::SavedJobSort < RecordSort
  def options
    [
      SortOption.new("created_at", I18n.t("jobs.sort_by.created_at.descending.saved_job"), "desc"),
      SortOption.new("vacancies.expires_at", I18n.t("jobs.sort_by.expires_at.ascending.saved_job"), "asc"),
      SortOption.new("vacancies.job_title", I18n.t("jobs.sort_by.job_title.ascending"), "asc"),
      SortOption.new("vacancies.readable_job_location", I18n.t("jobs.sort_by.location.ascending"), "asc"),
    ]
  end
end
