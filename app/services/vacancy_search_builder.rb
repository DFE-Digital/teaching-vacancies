class VacancySearchBuilder
  def initialize(filters:, sort:, expired: false, status: :published)
    @keyword = filters.keyword.to_s.strip
    @sort = sort
    @expired = expired
    @status = status
  end

  def call
    keyword_query = keyword_build
    expired_query = expired_build
    status_query = status_build
    sort_query = sort_build

    joined_query = [keyword_query, expired_query, status_query].compact

    query = {
      bool: {
        must: joined_query,
      },
    }
    { search_query: query, search_sort: sort_query }
  end

  private

  def keyword_build
    if @keyword.empty?
      {
        match_all: {},
      }
    else
      {
        multi_match: {
          query: @keyword,
          fields: %w[job_title^5 headline^2 job_description],
          operator: 'and',
        },
      }
    end
  end

  def expired_build
    return if @expired
    {
      range: {
        'expires_on': {
          'gte': 'now/d',
        },
      },
    }
  end

  def status_build
    return if @status.blank?
    {
      bool: {
        filter: {
          terms: {
            status: [@status.to_s],
          },
        },
      },
    }
  end

  def sort_build
    [{ @sort.column.to_sym => { order: @sort.order.to_sym } }]
  end
end