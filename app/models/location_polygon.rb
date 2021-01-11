class LocationPolygon < ApplicationRecord
  scope :cities, -> { where(location_type: "cities") }
  scope :counties, -> { where(location_type: "counties") }
  scope :london_boroughs, -> { where(location_type: "london_boroughs") }
  scope :regions, -> { where(location_type: "regions") }

  def self.with_name(location)
    find_by(name: (MAPPED_POLYGON_LOCATIONS[location.downcase].presence || location).downcase)
  end
end
