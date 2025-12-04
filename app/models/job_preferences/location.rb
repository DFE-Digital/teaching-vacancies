require_dependency "geocoding"

class JobPreferences < ApplicationRecord
  class Location < ApplicationRecord
    include DistanceHelper

    self.table_name = "job_preferences_locations"
    belongs_to :job_preferences
    self.ignored_columns += %i[area]

    validates :name, presence: true
    validates :radius, presence: true
    validates :uk_area, presence: true

    before_validation :set_area

    scope :containing, ->(point) { where("ST_Within(ST_GeomFromEWKT(?), uk_area::geometry)", "SRID=#{point.srid};#{point}") }

    private

    def set_area
      if LocationPolygon.contain?(name)
        self.uk_area = LocationPolygon.buffered(radius).with_name(name).uk_area
      else
        lat, long = Geocoding.new(name).coordinates.map(&:to_s)
        radius_metres = convert_miles_to_metres(Search::RadiusBuilder.new(name, radius).radius)
        area = GeoFactories::FACTORY_4326.point(long, lat).buffer(radius_metres)

        self.uk_area = GeoFactories.convert_wgs84_to_sr27700(area)
      end
    end
  end
end
