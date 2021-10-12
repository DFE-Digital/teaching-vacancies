class LocationPolygon < ApplicationRecord
  extend DistanceHelper

  # Scope that expands any polygons returned by subsequent scopes by the provided radius
  # by overriding the `area` attribute with a buffered version of itself
  #
  # TODO: This is a "clever" temporary solution to allow us to generate expanded polygons
  #       to send to Algolia, and should be removed once we search through ActiveRecord.
  scope :buffered, ->(radius_in_miles) { select("*, ST_Buffer(area, #{convert_miles_to_metres(radius_in_miles)}) AS area") }

  def self.with_name(location)
    find_by(name: mapped_name(location))
  end

  def self.include?(location)
    ALL_IMPORTED_LOCATIONS.include?(mapped_name(location))
  end

  def self.composite?(location)
    component_location_names(location).present?
  end

  def self.component_location_names(location)
    DOWNCASE_COMPOSITE_LOCATIONS[mapped_name(location)]
  end

  def self.mapped_name(location)
    (MAPPED_LOCATIONS[location&.downcase].presence || location)&.downcase
  end

  # Returns the coordinates of this location (multi)polygon in the format expected by Algolia
  def to_algolia_polygons
    # Reversing original coordinates as PostGIS uses lon,lat whereas Algolia uses lat,lon
    area.coordinates.map { |polygon| polygon.flatten.reverse }
  end
end
