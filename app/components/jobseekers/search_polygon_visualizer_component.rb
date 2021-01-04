class Jobseekers::SearchPolygonVisualizerComponent < ViewComponent::Base
  def initialize(vacancies_search:)
    @vacancies_search = vacancies_search
  end

  def render?
    @vacancies_search.location_search.search_polygon_boundary.present?
  end

  def search_polygon_boundary
    polygon = @vacancies_search.location_search.search_polygon_boundary.first
                               .each_slice(2).to_a.map { |element| { lat: element.first, lng: element.second } }
    polygon.to_json
  end
end
