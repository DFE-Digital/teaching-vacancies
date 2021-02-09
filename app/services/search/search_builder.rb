class Search::SearchBuilder
  DEFAULT_HITS_PER_PAGE = 10
  DEFAULT_PAGE = 1

  attr_reader :hits_per_page, :keyword, :location_search, :page, :params_hash,
              :point_coordinates, :search_filters, :search_replica, :sort_by, :stats, :total_count, :vacancies,
              :wider_search_suggestions

  def initialize(form_hash)
    @params_hash = form_hash
    @keyword = @params_hash[:keyword]
    @hits_per_page = (@params_hash[:per_page] || DEFAULT_HITS_PER_PAGE).to_i
    @page = (@params_hash[:page] || DEFAULT_PAGE).to_i

    build_location_search
    build_search_filters
    build_search_replica
    call_search
    build_suggestions if @vacancies.empty? && any?
  end

  def only_active_to_hash
    @params_hash.merge(keyword: @keyword).delete_if do |k, v|
      v.blank? || (k.eql?(:radius) && @params_hash[:location].blank?) || k.eql?(:jobs_sort) || k.eql?(:page)
    end
  end

  def any?
    filters = only_active_to_hash.dup
    filters.delete_if { |k, _| k.eql?(:radius) }
    filters.any?
  end

  private

  def build_location_search
    @location_search = Search::LocationBuilder.new(@params_hash[:location], @params_hash[:radius], @params_hash[:buffer_radius])
    @point_coordinates = @location_search.location_filter[:point_coordinates]
  end

  def build_search_filters
    @search_filters = Search::FiltersBuilder.new(@params_hash).filter_query
  end

  def build_search_replica
    replica = Search::ReplicaBuilder.new(@params_hash[:jobs_sort], @keyword)
    @search_replica = replica.search_replica
    @sort_by = replica.sort_by
  end

  def build_suggestions
    if @point_coordinates.present?
      @wider_search_suggestions = Search::RadiusSuggestionsBuilder.new(@params_hash[:radius], search_params).radius_suggestions
    elsif @location_search.polygon_boundaries.present?
      @wider_search_suggestions = Search::BufferSuggestionsBuilder.new(@params_hash[:location], search_params).buffer_suggestions
    end
  end

  def call_search
    search = if any?
               Search::AlgoliaSearchRequest.new(search_params)
             else
               Search::VacancyPaginator.new(page, hits_per_page, params_hash[:jobs_sort])
             end
    @vacancies = search.vacancies || []
    @stats = search.stats || []
    @total_count = search.total_count
  end

  def search_params
    {
      keyword: @keyword,
      coordinates: @location_search.location_filter[:point_coordinates],
      radius: @location_search.location_filter[:radius],
      polygons: @location_search.polygon_boundaries,
      filters: @search_filters,
      replica: @search_replica,
      hits_per_page: @hits_per_page,
      page: @page,
    }.compact
  end
end
