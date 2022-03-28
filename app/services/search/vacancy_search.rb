class Search::VacancySearch
  DEFAULT_HITS_PER_PAGE = 20
  DEFAULT_PAGE = 1

  extend Forwardable
  def_delegators :location_search, :point_coordinates

  attr_reader :search_criteria, :keyword, :location, :radius, :commute_location, :transportation_type, :travel_time, :sort, :page, :per_page

  def initialize(search_criteria, sort: nil, page: nil, per_page: nil)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @location = search_criteria[:location]
    @radius = search_criteria[:radius]

    @commute_location = search_criteria[:commute_location]
    @transportation_type = search_criteria[:transportation_type]
    @travel_time = search_criteria[:travel_time]

    @sort = sort || Search::VacancySort.new(keyword: keyword)
    @per_page = (per_page || DEFAULT_HITS_PER_PAGE).to_i
    @page = (page || DEFAULT_PAGE).to_i
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

  def wider_search_suggestions
    return unless vacancies.empty? && search_criteria[:location].present?

    Search::WiderSuggestionsBuilder.new(search_criteria).suggestions
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

  def vacancies
    @vacancies ||= scope.page(page).per(per_page)
  end

  def total_count
    vacancies.total_count
  end

  def commute_area
    @commute_area ||= TravelTime.new(commute_location, transportation_type, travel_time).commute_area
  end

  private

  def scope
    scope = Vacancy.live.includes(:organisations)
    scope = scope.search_within_area(commute_area) if commute_location && transportation_type && travel_time
    scope = scope.search_by_location(location, radius) if location
    scope = scope.search_by_filter(search_criteria) if search_criteria.any?
    scope = scope.search_by_full_text(keyword) if keyword.present?
    scope = scope.reorder(sort.by => sort.order) if sort&.by_db_column?
    scope
  end
end
