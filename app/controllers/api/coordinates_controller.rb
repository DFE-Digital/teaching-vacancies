require 'geocoding'

class Api::CoordinatesController < Api::ApplicationController
  before_action :verify_same_domain, only: ['show']
  before_action :verify_json_request, only: ['show']

  def show
    lat, lng = Geocoding.new(location).coordinates
    render json: {
      lat: lat,
      lng: lng,
      query: location,
      success: success?(lat, lng)
    }
  end

  private

  def location
    params[:location]
  end

  def success?(lat, lng)
    lat != 0 && lng != 0
  end
end
