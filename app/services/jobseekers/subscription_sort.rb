class Jobseekers::SubscriptionSort < RecordSort
  def options
    [
      SortOption.new("created_at", I18n.t("jobs.sort_by.created_at.descending.subscription"), "desc"),
      SortOption.new("frequency", I18n.t("jobs.sort_by.frequency.ascending"), "asc"),
    ]
  end
end
