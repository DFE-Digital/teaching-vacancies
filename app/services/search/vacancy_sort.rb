class Search::VacancySort < RecordSort
  def initialize(keyword:)
    @keyword = keyword
    super
  end

  def options
    # Do not allow relevance sort order when no keywords are given as it makes no sense
    if keyword.blank?
      [publish_on_desc_option]
    else
      [relevance_option, publish_on_desc_option]
    end
  end

  private

  attr_reader :keyword

  def default_sort_option
    options.include?(relevance_option) ? relevance_option : publish_on_desc_option
  end

  def relevance_option
    @relevance_option ||= SortOption.new("relevance", I18n.t("jobs.sort_by.most_relevant"))
  end

  def publish_on_desc_option
    SortOption.new("publish_on", I18n.t("jobs.sort_by.publish_on.descending"), "desc")
  end
end
