class LocationPolygon < ApplicationRecord
  scope :cities, -> { where(location_type: "cities") }
  scope :counties, -> { where(location_type: "counties") }
  scope :regions, -> { where(location_type: "regions") }

  def self.with_name(location)
    find_by(name: (MAPPED_LOCATIONS[location.downcase].presence || location).downcase)
  end
end
