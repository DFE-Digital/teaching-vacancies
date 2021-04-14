class Publishers::JobApplicationSort < RecordSort
  def initialize
    @column = options.first.column
    @order = options.first.order
  end

  def options
    [
      SortOption.new("submitted_at", "desc", I18n.t("publishers.vacancies.job_applications.index.sort_by.date_received")),
      SortOption.new("last_name", "asc", I18n.t("publishers.vacancies.job_applications.index.sort_by.applicant_last_name")),
    ]
  end
end
