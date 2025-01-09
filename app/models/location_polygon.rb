class LocationPolygon < ApplicationRecord
  extend DistanceHelper

  validates :name, presence: true

  # Scope that expands any polygons returned by subsequent scopes by the provided radius
  # by overriding the `area` attribute with a buffered version of itself
  scope :buffered, ->(radius_in_miles) { select("*, ST_Buffer(area, #{convert_miles_to_metres(radius_in_miles || 0)}) AS area") }

  def self.with_name(location)
    find_by(name: mapped_name(location))
  end

  def self.contain?(location)
    with_name(location).present?
  end

  def self.mapped_name(location)
    (MAPPED_LOCATIONS[location&.downcase].presence || location)&.downcase
  end
end
