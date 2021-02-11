class Search::VacancySearch
  DEFAULT_HITS_PER_PAGE = 10
  DEFAULT_PAGE = 1

  extend Forwardable
  def_delegators :search_strategy, :vacancies, :total_count
  def_delegators :location_search, :point_coordinates

  attr_reader :params, :keyword, :page, :hits_per_page

  def initialize(params)
    @params = params
    @keyword = params[:keyword]
    @hits_per_page = (params[:per_page] || DEFAULT_HITS_PER_PAGE).to_i
    @page = (params[:page] || DEFAULT_PAGE).to_i
  end

  def active_criteria
    params
      .except(:jobs_sort, :page)
      .reject { |k, v| v.blank? || (k == :radius && params[:location].blank?) }
  end

  def active_criteria?
    active_criteria.any?
  end

  def location_search
    @location_search ||= Search::LocationBuilder.new(params[:location], params[:radius], params[:buffer_radius])
  end

  def search_filters
    @search_filters ||= Search::FiltersBuilder.new(params).filter_query
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
                                    Search::RadiusSuggestionsBuilder.new(params[:radius], search_params).radius_suggestions
                                  elsif location_search.polygon_boundaries.present?
                                    Search::BufferSuggestionsBuilder.new(params[:location], search_params).buffer_suggestions
                                  end
  end

  def out_of_bounds?
    page_from > total_count
  end

  def page_from
    (page - 1) * hits_per_page + 1
  end

  def page_to
    [(page * hits_per_page), total_count].min
  end

  private

  def replica_builder
    @replica_builder ||= Search::ReplicaBuilder.new(params[:jobs_sort], keyword)
  end

  def search_strategy
    @search_strategy ||= if active_criteria?
                           Search::Strategies::Algolia.new(search_params)
                         else
                           Search::Strategies::Database.new(page, hits_per_page, params[:jobs_sort])
                         end
  end

  def search_params
    {
      keyword: keyword,
      coordinates: location_search.location_filter[:point_coordinates],
      radius: location_search.location_filter[:radius],
      polygons: location_search.polygon_boundaries,
      filters: search_filters,
      replica: search_replica,
      hits_per_page: hits_per_page,
      page: page,
    }.compact
  end
end
