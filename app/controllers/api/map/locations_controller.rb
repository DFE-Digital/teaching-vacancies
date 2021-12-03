class Api::Map::LocationsController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show]

  def show
    render json: [location]
  end

  private

  def location_search
    Search::LocationBuilder.new(params[:id], params[:radius])
  end

  def polygon
    location_search.polygon_boundaries.each_with_object([]) do |boundary, points|
      boundary.each_slice(2).map { |element| points.push({ lat: element.first, lng: element.second }) }
    end
  end

  def location
    {
      type: "polygon",
      data: {
        point: location_search.point_coordinates,
        meta: {},
        coordinates: polygon,
      }
    }
  end
end
