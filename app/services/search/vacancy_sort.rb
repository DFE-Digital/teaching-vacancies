class Search::VacancySort < RecordSort
  def initialize(keyword:, location: nil)
    @keyword = keyword
    @location = location
    super
  end

  def options
    if location.present?
      [distance_option, publish_on_non_default_desc_option, closing_date_asc_option]
    else
      [publish_on_desc_option, closing_date_asc_option]
    end
  end

  def default_sort_option
    if location.present?
      distance_option
    else
      publish_on_desc_option
    end
  end

  def by_db_column?
    return true if sort_by == "publish_on_non_default"

    super
  end

  private

  attr_reader :keyword, :location

  def publish_on_desc_option
    SortOption.new("publish_on", I18n.t("jobs.sort_by.publish_on.descending"), "desc")
  end

  def closing_date_asc_option
    SortOption.new("expires_at", I18n.t("jobs.sort_by.expires_at.ascending.vacancy.jobseeker"), "asc")
  end

  def distance_option
    SortOption.new("distance", "Distance", "asc")
  end

  def publish_on_non_default_desc_option
    SortOption.new("publish_on_non_default", I18n.t("jobs.sort_by.publish_on.descending"), "desc")
  end
end
