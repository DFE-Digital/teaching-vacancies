class Search::SearchBuilder
  DEFAULT_HITS_PER_PAGE = 10
  DEFAULT_PAGE = 1

  attr_reader :params_hash, :keyword, :page, :hits_per_page, :total_count, :vacancies

  def initialize(form_hash)
    @params_hash = form_hash
    @keyword = @params_hash[:keyword]
    @hits_per_page = (@params_hash[:per_page] || DEFAULT_HITS_PER_PAGE).to_i
    @page = (@params_hash[:page] || DEFAULT_PAGE).to_i

    call_search
  end

  def only_active_to_hash
    @params_hash
      .except(:jobs_sort, :page)
      .reject { |k, v| v.blank? || (k == :radius && @params_hash[:location].blank?) }
  end

  def any_criteria_given?
    only_active_to_hash.except(:radius).any?
  end

  def location_search
    @location_search ||= Search::LocationBuilder.new(@params_hash[:location], @params_hash[:radius], @params_hash[:buffer_radius])
  end

  def point_coordinates
    @point_coordinates ||= location_search.location_filter[:point_coordinates]
  end

  def search_filters
    @search_filters ||= Search::FiltersBuilder.new(@params_hash).filter_query
  end

  def search_replica
    @search_replica ||= replica_builder.search_replica
  end

  def sort_by
    @sort_by ||= replica_builder.sort_by
  end

  def wider_search_suggestions
    return unless @vacancies.empty? && any_criteria_given?

    @wider_search_suggestions ||= if point_coordinates.present?
                                    Search::RadiusSuggestionsBuilder.new(@params_hash[:radius], search_params).radius_suggestions
                                  elsif location_search.polygon_boundaries.present?
                                    Search::BufferSuggestionsBuilder.new(@params_hash[:location], search_params).buffer_suggestions
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
    @replica_builder ||= Search::ReplicaBuilder.new(@params_hash[:jobs_sort], @keyword)
  end

  def call_search
    search = if any_criteria_given?
               Search::AlgoliaSearchRequest.new(search_params)
             else
               Search::VacancyPaginator.new(page, hits_per_page, params_hash[:jobs_sort])
             end
    @vacancies = search.vacancies || []
    @total_count = search.total_count
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
