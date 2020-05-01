require 'geocoding'

class Api::CoordinatesController < Api::ApplicationController
  before_action :verify_json_request, only: ['show']

  def show
    x, y = Geocoding.new(location).coordinates
    render json: { "x": x, "y": y }
  end

  private

  def location
    params[:location]
  end
end
