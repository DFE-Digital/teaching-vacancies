class VacancyAlertSearchBuilder < VacancySearchBuilder
  attr_accessor :keyword,
                :maximum_salary

  def initialize(filters:, from:, to:)
    @from = from
    @to = to
    sort = VacancySort.new.update(column: 'publish_on', order: 'desc')

    self.keyword = filters.keyword.to_s.strip
    self.maximum_salary = filters.maximum_salary

    super(filters: filters, sort: sort, expired: false, status: :published)
  end

  private

  def must_query_clause
    super().concat([keyword_query]).compact.uniq
  end

  def keyword_query
    return if keyword.blank?

    {
      multi_match: {
        query: keyword,
        fields: %w[job_title^3 subject.name first_supporting_subject.name second_supporting_subject.name],
        operator: 'and',
        fuzziness: 2,
        prefix_length: 1
      }
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

  def salary_query
    return if minimum_salary.blank?

    [
      {
        bool: {
          should: [
            {
              bool: {
                must: [
                  range: {
                    "maximum_salary": {
                      gte: minimum_salary.to_i
                    }
                  }
                ]
              }
            },
            {
              bool: {
                must_not: {
                  exists: {
                    field: 'maximum_salary'
                  }
                }
              }
            }
          ]
        }
      }
    ]
  end

  def less_than_minimum_and_maximum_match
    [less_than(maximum_salary: maximum_salary.to_i),
     less_than_maximum_salary_or_no_match]
  end

  def less_than_maximum_salary_or_no_match
    {
      bool: {
        should: [
          less_than(maximum_salary: maximum_salary.to_i),
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
