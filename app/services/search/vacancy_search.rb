class Search::VacancySearch
  extend Forwardable
  def_delegators :location_search, :point_coordinates

  attr_reader :search_criteria, :keyword, :location, :radius, :organisation_slug, :sort

  def initialize(search_criteria, sort: nil)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @location = search_criteria[:location]
    @radius = search_criteria[:radius]
    @organisation_slug = search_criteria[:organisation_slug]

    @sort = sort || Search::VacancySort.new(keyword: keyword)
  end

  def active_criteria
    search_criteria
      .reject { |k, v| v.blank? || (k == :radius && search_criteria[:location].blank?) }
  end

  def clear_filters_params
    active_criteria.merge(job_roles: [], ect_statuses: [], phases: [], working_patterns: [], subjects: [], previous_keyword: keyword, skip_strip_checkboxes: true)
  end

  def remove_filter_params
    active_criteria.merge(previous_keyword: keyword)
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

  def organisation
    Organisation.find_by(slug: organisation_slug) if organisation_slug
  end

  def vacancies
    @vacancies ||= scope
  end

  def markers
    @markers ||= Marker.search_by_location(location, radius)
                       .where(vacancy_id: scope.pluck(:id))
                       .pluck(:vacancy_id, :organisation_id, :geopoint)
                       .map { |marker| marker_for_map(*marker) }
  end

  def total_count
    vacancies.count
  end

  private

  def scope
    scope = Vacancy.live.includes(:organisations)
    scope = scope.where(id: organisation.all_vacancies.pluck(:id)) if organisation
    scope = scope.search_by_location(location, radius) if location
    scope = scope.search_by_filter(search_criteria) if search_criteria.any?
    scope = scope.search_by_full_text(keyword) if keyword.present?
    scope = scope.reorder(sort.by => sort.order) if sort&.by_db_column?
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
