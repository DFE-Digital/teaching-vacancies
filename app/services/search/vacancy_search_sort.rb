class Search::VacancySearchSort
  attr_reader :key, :display_name, :column, :order, :algolia_replica_suffix

  def self.options
    OPTIONS
  end

  def self.for(key, keyword:)
    option = options.find { |o| o.key.to_s == key.to_s } || RELEVANCE

    # Do not allow relevance sort order when no keywords are given as it makes no sense
    return PUBLISH_ON_DESC if option == RELEVANCE && keyword.blank?

    option
  end

  def initialize(key, display_name, column: nil, order: nil, algolia_replica_suffix: nil)
    @key = key
    @display_name = display_name

    @column = column
    @order = order
    @algolia_replica_suffix = algolia_replica_suffix
  end
  private :initialize

  OPTIONS = [
    RELEVANCE = new(:relevance, I18n.t("jobs.sort_by.most_relevant")),
    PUBLISH_ON_DESC = new(
      :publish_on_desc,
      I18n.t("jobs.sort_by.publish_on.descending"),
      column: :publish_on,
      order: :desc,
      algolia_replica_suffix: "publish_on_desc",
    ),
    EXPIRES_AT_DESC = new(
      :expires_at_desc,
      I18n.t("jobs.sort_by.expires_at.descending.vacancy.jobseeker"),
      column: :expires_at,
      order: :desc,
      algolia_replica_suffix: "expires_at_desc",
    ),
    EXPIRES_AT_ASC = new(
      :expires_at_asc,
      I18n.t("jobs.sort_by.expires_at.ascending.vacancy.jobseeker"),
      column: :expires_at,
      order: :asc,
      algolia_replica_suffix: "expires_at_asc",
    ),
  ].freeze

  def to_s
    key.to_s
  end

  def algolia_replica
    return nil unless algolia_replica_suffix.present?

    [Vacancy::Indexable::INDEX_NAME, algolia_replica_suffix].join("_")
  end
end
