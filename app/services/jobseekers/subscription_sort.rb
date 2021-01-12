class Jobseekers::SubscriptionSort < RecordSort
  def initialize
    @column = options.first.column
    @order = options.first.order
  end

  def options
    [
      SortOption.new("created_at", "desc", I18n.t("jobs.sort_by.created_at.descending.subscription")),
      SortOption.new("frequency", "asc", I18n.t("jobs.sort_by.frequency.ascending")),
    ]
  end
end
