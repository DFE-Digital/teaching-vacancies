require_dependency "geocoding"

class JobPreferences < ApplicationRecord
  class Location < ApplicationRecord
    include DistanceHelper

    self.table_name = "job_preferences_locations"
    belongs_to :job_preferences

    validates :name, presence: true
    validates :radius, presence: true
    validates :area, presence: true

    before_validation :set_area

    scope :containing, ->(point) { where("ST_Within(ST_GeomFromEWKT(?), area::geometry)", "SRID=4326;#{point.as_text}") }

    private

    def set_area
      if LocationPolygon.contain?(name)
        self.area = LocationPolygon.buffered(radius).with_name(name).area
      else
        lat, long = Geocoding.new(name).coordinates.map(&:to_s)
        radius_meters = convert_miles_to_metres(Search::RadiusBuilder.new(name, radius).radius)
        self.area = RGeo::Geographic.spherical_factory(srid: 4326).point(long, lat).buffer(radius_meters)
      end
    end
  end
end
