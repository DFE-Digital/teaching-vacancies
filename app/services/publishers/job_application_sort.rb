class Publishers::JobApplicationSort < RecordSort
  def options
    [submitted_at_desc_option, last_name_option]
  end

  private

  def last_name_option
    @last_name_option ||= SortOption.new("last_name", I18n.t("publishers.vacancies.job_applications.index.sort_by.applicant_last_name"))
  end

  def submitted_at_desc_option
    @submitted_at_desc_option ||= SortOption.new("submitted_at", I18n.t("publishers.vacancies.job_applications.index.sort_by.date_received"), "desc")
  end
end
