class Jobseekers::SearchResults::SearchVisualizerComponent < ViewComponent::Base
  def initialize(vacancies_search:, render:)
    @vacancies_search = vacancies_search
    @render = render
  end

  def render?
    @render
  end

  def point_coordinates
    return unless @vacancies_search.point_coordinates.present?

    { lat: @vacancies_search.point_coordinates.first, lng: @vacancies_search.point_coordinates.second }.to_json
  end

  def polygon_boundaries
    return unless @vacancies_search.location_search.polygon_boundaries.present?

    @polygon_boundaries ||=
      @vacancies_search.location_search.polygon_boundaries.map { |boundary|
        boundary.each_slice(2).to_a.map { |element| { lat: element.first, lng: element.second } }
      }.to_json
  end
end
