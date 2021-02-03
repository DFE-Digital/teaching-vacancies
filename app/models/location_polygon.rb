class LocationPolygon < ApplicationRecord
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
end
