require 'elasticsearch'

class ElasticSearchFinder
  def call(query, sort)
    Vacancy.__elasticsearch__.search(size: size, query: query, sort: sort)
  end

  def size
    Vacancy.default_per_page
  end
end
