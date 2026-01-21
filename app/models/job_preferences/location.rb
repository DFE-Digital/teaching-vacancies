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

    scope :containing, ->(point) { where(arel_table[:uk_area].st_contains(point)) }

    private

    def set_area
      if LocationPolygon.contain?(name)
        # :nocov:
        self.uk_area = LocationPolygon.buffered(radius).with_name(name).uk_area
        # :nocov:
      else
        lat, long = Geocoding.new(name).coordinates.map(&:to_s)
        radius_meters = convert_miles_to_metres(Search::RadiusBuilder.new(name, radius).radius)
        self.uk_area = GeoFactories.convert_wgs84_to_sr27700(GeoFactories::FACTORY_4326.point(long, lat).buffer(radius_meters))
      end
    end
  end
end
