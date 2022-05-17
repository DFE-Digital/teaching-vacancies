class Search::VacancySearch
  DEFAULT_HITS_PER_PAGE = 20
  DEFAULT_PAGE = 1

  extend Forwardable
  def_delegators :location_search, :point_coordinates

  attr_reader :search_criteria, :keyword, :location, :radius, :organisation_slug,
              :transportation_type, :travel_time, :sort, :page, :per_page

  def initialize(search_criteria, sort: nil, page: nil, per_page: nil)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @organisation_slug = search_criteria[:organisation_slug]
    @location = search_criteria[:location]
    @transportation_type = search_criteria[:transportation_type]
    @travel_time = search_criteria[:travel_time]
    @radius = commute_area_search? ? 0 : search_criteria[:radius]

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
    @location_search ||= Search::LocationBuilder.new(location, radius)
  end

  def wider_search_suggestions
    return if commute_area_search?
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

  def organisation
    Organisation.find_by(slug: organisation_slug) if organisation_slug
  end

  def polygon
    return unless location_search.geojson_polygon.present? || commute_area_search?

    commute_area_search? ? RGeo::GeoJSON.encode(commute_area) : location_search.geojson_polygon
  end

  def vacancies
    @vacancies ||= vacancies_scope.page(page).per(per_page)
  end

  def markers
    @markers ||= markers_scope.pluck(:vacancy_id, :organisation_id, :geopoint)
                              .map { |marker| marker_for_map(*marker) }
  end

  def total_count
    vacancies.total_count
  end

  def commute_area
    @commute_area ||= TravelTime.new(location, transportation_type, travel_time).commute_area
  end

  def commute_area_search?
    location.present? && transportation_type.present? && travel_time.present?
  end

  private

  def vacancies_scope # rubocop:disable Metrics/AbcSize
    scope = Vacancy.live.includes(:organisations)
    scope = scope.where(id: organisation.all_vacancies.pluck(:id)) if organisation
    scope = scope.search_by_location(location, radius) if location.present? && !commute_area_search?
    scope = scope.search_within_area(commute_area) if commute_area_search?
    scope = scope.search_by_filter(search_criteria) if search_criteria.any?
    scope = scope.search_by_full_text(keyword) if keyword.present?
    scope = scope.reorder(sort.by => sort.order) if sort&.by_db_column?
    scope
  end

  def markers_scope
    scope = Marker.where(vacancy_id: vacancies_scope.pluck(:id))
    scope = scope.search_by_location(location, radius) if location.present? && !commute_area_search?
    scope = scope.search_within_area(commute_area) if commute_area_search?
    scope
  end

  def marker_for_map(vacancy_id, organisation_id, geopoint)
    {
      id: vacancy_id,
      parent_id: organisation_id,
      geopoint: RGeo::GeoJSON.encode(geopoint)&.to_json,
    }
  end
end
