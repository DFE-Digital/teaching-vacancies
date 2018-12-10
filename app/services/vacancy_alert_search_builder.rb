class VacancyAlertSearchBuilder < VacancySearchBuilder
  def initialize(filters:, from:, to:)
    @from = from
    @to = to
    sort = VacancySort.new.update(column: 'publish_on', order: 'desc')

    super(filters: filters, sort: sort, expired: false, status: :published)
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
