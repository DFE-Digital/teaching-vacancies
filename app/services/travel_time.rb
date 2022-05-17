require "geocoding"

class TravelTime
  TIME_MAP_ENDPOINT_URL = "https://api.traveltimeapp.com/v4/time-map".freeze

  def initialize(location, transportation_type, travel_time_in_minutes)
    @location = location
    @transportation_type = transportation_type
    @travel_time_in_minutes = travel_time_in_minutes
  end

  def commute_area
    shapes = response["results"] ? response["results"].first["shapes"] : []
    polygons = shapes.map { |shape| polygon_from_points(shape) }
    factory.multi_polygon(polygons)
  end

  private

  def response
    HTTParty.post(TIME_MAP_ENDPOINT_URL, headers: headers, body: payload.to_json)
  end

  def headers
    {
      "Content-Type": "application/json",
      "X-Application-Id": ENV.fetch("TRAVELTIME_APPLICATION_ID", nil),
      "X-Api-Key": ENV.fetch("TRAVELTIME_APPLICATION_KEY", nil),
    }
  end

  def payload
    {
      departure_searches: [
        {
          id: @location,
          coords: location_coordinates,
          transportation: {
            type: @transportation_type,
          },
          departure_time: next_monday_morning,
          travel_time: @travel_time_in_minutes.to_i * 60,
        },
      ],
    }
  end

  def factory
    @factory ||= RGeo::ActiveRecord::SpatialFactoryStore.instance.default
  end

  def polygon_from_points(shape)
    points = shape["shell"].map { |point| factory.point(*point.values.reverse) }

    factory.polygon(factory.linear_ring(points))
  end

  def location_coordinates
    coordinates = Geocoding.new(@location).coordinates

    { lat: coordinates.first, lng: coordinates.last }
  end

  def next_monday_morning
    Time.current.next_occurring(:monday).change(hour: 8).iso8601
  end
end
