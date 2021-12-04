class Api::Map::LocationsController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show]

  def show
    render json: [location]
  end

  private

  def location
    return polygon if location_search.search_with_polygons?

    marker
  end

  def location_search
    @location_search ||= Search::LocationBuilder.new(params[:id], params[:radius])
  end

  def polygon
    {
      type: "polygon",
      data: {
        point: Geocoding.new(params[:id]).coordinates,
        meta: {},
        coordinates: coordinates,
      },
    }
  end

  def marker
    {
      type: "marker",
      data: {
        point: location_search.point_coordinates,
      },
    }
  end

  def coordinates
    location_search.polygon_boundaries.each_with_object([]) do |boundary, points|
      boundary.each_slice(2).map { |element| points << { lat: element.first, lng: element.second } }
    end
  end
end
