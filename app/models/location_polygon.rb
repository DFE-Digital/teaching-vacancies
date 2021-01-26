class LocationPolygon < ApplicationRecord
  scope :cities, -> { where(location_type: "cities") }
  scope :counties, -> { where(location_type: "counties") }
  scope :regions, -> { where(location_type: "regions") }
  scope :other, -> { where(location_type: "other") }

  def self.with_name(location)
    find_by(name: (MAPPED_LOCATIONS[location.downcase].presence || location).downcase)
  end
end
