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

  def salary_query
    return if minimum_salary.blank? && maximum_salary.blank?
    return greater_than(:minimum_salary, minimum_salary.to_i) if maximum_salary.blank?
    return less_than_minimum_and_maximum_match if minimum_salary.blank?

    [greater_than(:minimum_salary, minimum_salary.to_i), less_than_maximum_salary_or_no_match]
  end

  def less_than_minimum_and_maximum_match
    [less_than(:minimum_salary, maximum_salary.to_i), less_than_maximum_salary_or_no_match]
  end

  def less_than_maximum_salary_or_no_match
    {
      bool: {
        should: [
          less_than(:maximum_salary, maximum_salary.to_i),
          bool: {
            must_not: {
              exists: {
                field: 'maximum_salary'
              }
            }
          }
        ]
      }
    }
  end
end
