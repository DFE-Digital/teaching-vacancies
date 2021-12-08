class Search::VacancySearch
  DEFAULT_HITS_PER_PAGE = 20
  DEFAULT_PAGE = 1

  extend Forwardable
  def_delegators :search_strategy, :vacancies, :total_count
  def_delegators :location_search, :point_coordinates

  attr_reader :search_criteria, :keyword, :sort_by, :page, :per_page, :fuzzy

  def initialize(search_criteria, sort_by: nil, page: nil, per_page: nil, fuzzy: true)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]

    @sort_by = sort_by || Search::VacancySearchSort::RELEVANCE
    @per_page = (per_page || DEFAULT_HITS_PER_PAGE).to_i
    @page = (page || DEFAULT_PAGE).to_i
    @fuzzy = fuzzy
  end

  def active_criteria
    search_criteria
      .reject { |k, v| v.blank? || (k == :radius && search_criteria[:location].blank?) }
  end

  def active_criteria?
    active_criteria.any?
  end

  def location_search
    @location_search ||= Search::LocationBuilder.new(search_criteria[:location], search_criteria[:radius])
  end

  def search_filters
    @search_filters ||= Search::FiltersBuilder.new(search_criteria).filter_query
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
    ((page - 1) * per_page) + 1
  end

  def page_to
    [(page * per_page), total_count].min
  end

  private

  def search_strategy
    @search_strategy ||= Search::Strategies::PgSearch.new(
      keyword,
      filters: search_criteria,
      location: search_criteria[:location],
      radius: location_search.radius,
      page: page,
      per_page: per_page,
      sort_by: sort_by,
    )
  end

  def algolia_params
    {
      keyword: keyword,
      coordinates: location_search.location_filter[:point_coordinates],
      radius: location_search.location_filter[:radius],
      polygons: location_search.polygon_boundaries,
      filters: search_filters,
      replica: sort_by.algolia_replica,
      per_page: per_page,
      page: page,
      typo_tolerance: fuzzy,
    }.compact
  end
end
