class VacancyAlertSearchBuilder < VacancySearchBuilder
  attr_accessor :keyword

  def initialize(filters:, from:, to:)
    @from = from
    @to = to
    sort = VacancySort.new.update(column: 'publish_on', order: 'desc')

    self.keyword = filters.keyword.to_s.strip

    super(filters: filters, sort: sort, expired: false, status: :published)
  end

  private

  def must_query_clause
    super().concat([keyword_query]).compact
  end

  def keyword_query
    optional_query(keyword) { |keyword| keyword_multi_match(keyword) }
  end

  def keyword_multi_match(keyword)
    {
      multi_match: {
        query: keyword,
        fields: %w[job_title^3 subject.name first_supporting_subject.name second_supporting_subject.name],
        operator: 'and',
        fuzziness: 2,
        prefix_length: 1
      },
    }
  end

  def published_on_query
    {
      range: {
        'publish_on': {
          'gte': @from,
          'lt': @to
        },
      },
    }
  end
end
