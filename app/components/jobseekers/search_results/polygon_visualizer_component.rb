class Jobseekers::SearchResults::PolygonVisualizerComponent < ViewComponent::Base
  def initialize(vacancies_search:, auth:)
    @auth = auth
    @vacancies_search = vacancies_search
  end

  def render?
    @auth == true
  end

  def polygon_boundaries
    @polygon_boundaries ||=
      @vacancies_search.location_search.polygon_boundaries&.map do |boundary|
        boundary.each_slice(2).to_a.map { |element| { lat: element.first, lng: element.second } }
      end || "no polygons"
  end

  def no_polygons?
    polygon_boundaries == "no polygons"
  end
end
