class Api::LocationPolygonsController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show]

  def show
    location_polygon = LocationPolygon.find_by(name: location)

    render json: {
      location: location,
      polygon: location_polygon&.boundary,
      success: location_polygon.present?
    }
  end

  private

  def location
    params[:location]
  end
end
