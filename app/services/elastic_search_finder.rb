require 'elasticsearch'

class ElasticSearchFinder
  def call(query, sort)
    Vacancy.__elasticsearch__.search(size: 1000, query: query, sort: sort)
  end
end
