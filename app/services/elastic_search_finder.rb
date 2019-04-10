require 'elasticsearch'

class ElasticSearchFinder
  def call(query, sort, size = Vacancy.default_per_page)
    Vacancy.__elasticsearch__.search(size: size, query: query, sort: sort)
  end
end
