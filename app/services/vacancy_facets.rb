class VacancyFacets
  FIELDS = %i[job_roles subjects cities counties].freeze

  def initialize(store: Redis.new(url: REDIS_URL))
    @store = store
  end

  def get(field)
    return {} unless FIELDS.include?(field) && store.exists?(field)

    JSON.parse(store.get(field))
  end

  def refresh
    store.set(:job_roles, sort_and_limit(job_role_facet, 4).to_json)
    store.set(:subjects, sort_and_limit(subject_facet, 10).to_json)
    store.set(:cities, sort_and_limit(city_facet, 20).to_json)
    store.set(:counties, sort_and_limit(county_facet, 20).to_json)
  end

private

  attr_reader :store

  def sort_and_limit(facet, number_of_results)
    facet.sort_by { |_, count| -count }.first(number_of_results).sort.to_h
  end

  def job_role_facet
    Vacancy::JOB_ROLE_OPTIONS.keys.each_with_object({}) { |job_role, facets| facets[job_role] = algolia_facet_count(job_roles: [job_role]) }
  end

  def subject_facet
    SUBJECT_OPTIONS.each_with_object({}) { |subject, facets| facets[subject.first] = algolia_facet_count(keyword: subject.first) }
  end

  def city_facet
    CITIES.each_with_object({}) { |city, facets| facets[city] = algolia_facet_count(location: city) }
  end

  def county_facet
    COUNTIES.each_with_object({}) { |county, facets| facets[county] = algolia_facet_count(location: county) }
  end

  def algolia_facet_count(query)
    search = Search::VacancySearchBuilder.new(query)
    search.call.stats.last
  end
end
