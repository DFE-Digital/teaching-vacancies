class Search::VacancySearchSort
  attr_reader :key, :display_name, :column, :order

  def self.options
    OPTIONS
  end

  def self.for(key, keyword:)
    option = options.find { |o| o.key.to_s == key.to_s } || RELEVANCE

    # Do not allow relevance sort order when no keywords are given as it makes no sense
    return PUBLISH_ON_DESC if option == RELEVANCE && keyword.blank?

    option
  end

  def initialize(key, display_name, column: nil, order: nil)
    @key = key
    @display_name = display_name

    @column = column
    @order = order
  end
  private :initialize

  OPTIONS = [
    RELEVANCE = new(:relevance, I18n.t("jobs.sort_by.most_relevant")),
    PUBLISH_ON_DESC = new(
      :publish_on_desc,
      I18n.t("jobs.sort_by.publish_on.descending"),
      column: :publish_on,
      order: :desc,
    ),
    EXPIRES_AT_DESC = new(
      :expires_at_desc,
      I18n.t("jobs.sort_by.expires_at.descending.vacancy.jobseeker"),
      column: :expires_at,
      order: :desc,
    ),
    EXPIRES_AT_ASC = new(
      :expires_at_asc,
      I18n.t("jobs.sort_by.expires_at.ascending.vacancy.jobseeker"),
      column: :expires_at,
      order: :asc,
    ),
  ].freeze

  def to_s
    key.to_s
  end
end
