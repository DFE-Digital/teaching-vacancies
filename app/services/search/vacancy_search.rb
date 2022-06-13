class Search::VacancySearch
  DEFAULT_HITS_PER_PAGE = 20
  DEFAULT_PAGE = 1

  extend Forwardable
  def_delegators :location_search, :point, :polygon, :point_coordinates,
                 :area, :location_polygon, :radius_in_meters,
                 :commute_area_search?, :location_polygon_search?

  attr_reader :search_criteria, :keyword, :location, :radius, :organisation_slug,
              :transportation_type, :travel_time, :sort, :page, :per_page

  def initialize(search_criteria, sort: nil, page: nil, per_page: nil)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @location = search_criteria[:location]
    @radius = search_criteria[:radius]
    @transportation_type = search_criteria[:transportation_type]
    @travel_time = search_criteria[:travel_time]
    @organisation_slug = search_criteria[:organisation_slug]

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
    @location_search ||= Search::LocationBuilder.new(location, radius, travel_time, transportation_type)
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

  private

  def vacancies_scope
    scope = Vacancy.live.includes(:organisations)
    scope = scope.where(id: organisation.all_vacancies.pluck(:id)) if organisation
    scope = scope.search_within_area(area) if location_search.location
    scope = scope.search_by_filter(search_criteria) if search_criteria.any?
    scope = scope.search_by_full_text(keyword) if keyword.present?
    scope = scope.reorder(sort.by => sort.order) if sort&.by_db_column?
    scope
  end

  def markers_scope
    scope = Marker.where(vacancy_id: vacancies_scope.pluck(:id))
    scope = scope.search_within_area(area) if location_search.location
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
