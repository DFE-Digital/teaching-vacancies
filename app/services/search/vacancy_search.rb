class Search::VacancySearch
  DEFAULT_HITS_PER_PAGE = 10
  DEFAULT_PAGE = 1

  extend Forwardable
  def_delegators :search_strategy, :vacancies, :total_count
  def_delegators :location_search, :point_coordinates

  attr_reader :search_criteria, :keyword, :page, :per_page

  def initialize(search_criteria, page: nil, per_page: nil)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @per_page = (per_page || DEFAULT_HITS_PER_PAGE).to_i
    @page = (page || DEFAULT_PAGE).to_i
  end

  def active_criteria
    search_criteria
      .except(:jobs_sort)
      .reject { |k, v| v.blank? || (k == :radius && search_criteria[:location].blank?) }
  end

  def active_criteria?
    active_criteria.any?
  end

  def location_search
    @location_search ||= Search::LocationBuilder.new(search_criteria[:location], search_criteria[:radius], search_criteria[:buffer_radius])
  end

  def search_filters
    @search_filters ||= Search::FiltersBuilder.new(search_criteria).filter_query
  end

  def search_replica
    @search_replica ||= replica_builder.search_replica
  end

  def sort_by
    @sort_by ||= replica_builder.sort_by
  end

  def wider_search_suggestions
    return unless vacancies.empty? && active_criteria?

    @wider_search_suggestions ||= if point_coordinates.present?
                                    Search::RadiusSuggestionsBuilder.new(search_criteria[:radius], algolia_params).radius_suggestions
                                  elsif location_search.polygon_boundaries.present?
                                    Search::BufferSuggestionsBuilder.new(search_criteria[:location], algolia_params).buffer_suggestions
                                  end
  end

  def out_of_bounds?
    page_from > total_count
  end

  def page_from
    (page - 1) * per_page + 1
  end

  def page_to
    [(page * per_page), total_count].min
  end

  private

  def replica_builder
    @replica_builder ||= Search::ReplicaBuilder.new(search_criteria[:jobs_sort], keyword)
  end

  def search_strategy
    @search_strategy ||= if active_criteria?
                           Search::Strategies::Algolia.new(algolia_params)
                         else
                           Search::Strategies::Database.new(page, per_page, search_criteria[:jobs_sort])
                         end
  end

  def algolia_params
    {
      keyword: keyword,
      coordinates: location_search.location_filter[:point_coordinates],
      radius: location_search.location_filter[:radius],
      polygons: location_search.polygon_boundaries,
      filters: search_filters,
      replica: search_replica,
      per_page: per_page,
      page: page,
    }.compact
  end
end
