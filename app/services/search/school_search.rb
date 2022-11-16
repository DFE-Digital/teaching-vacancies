class Search::SchoolSearch
  extend Forwardable
  def_delegators :location_search, :point_coordinates

  attr_reader :search_criteria, :search_name, :location, :radius

  def initialize(search_criteria, scope: Organisation.all)
    @location = search_criteria[:location]
    @radius = search_criteria[:radius]
    @scope = scope
  end

  def active_criteria
    search_criteria
      .reject { |k, v| v.blank? || (k == :radius && search_criteria[:location].blank?) }
  end

  def active_criteria?
    active_criteria.any?
  end

  def wider_search_suggestions
    return unless vacancies.empty? && search_criteria[:location].present?

    Search::WiderSuggestionsBuilder.new(search_criteria).suggestions
  end

  def organisations
    @organisations ||= scope
  end

  def total_count
    schools.count
  end

  private

  def scope
    scope = @scope.all
    scope = scope.search_by_location(location, radius) if location.present?
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
