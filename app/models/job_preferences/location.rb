require_dependency "geocoding"

class JobPreferences < ApplicationRecord
  class Location < ApplicationRecord
    include DistanceHelper

    self.table_name = "job_preferences_locations"

    before_create :set_area

    private

    def set_area
      radius_meters = convert_miles_to_metres(Search::RadiusBuilder.new(name, radius).radius)

      if LocationPolygon.contain?(name)
        self.area = LocationPolygon.with_name(name).area.buffer(radius_meters)
      else
        lat, long = Geocoding.new(name).coordinates.map(&:to_s)
        self.area = RGeo::Geographic.spherical_factory.point(lat, long).buffer(radius_meters)
      end
    end
  end
end
