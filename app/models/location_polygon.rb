class LocationPolygon < ApplicationRecord
  extend DistanceHelper

  validates :name, presence: true

  # Scope that expands any polygons returned by subsequent scopes by the provided radius
  # by overriding the `area` attribute with a buffered version of itself
  scope :buffered, ->(radius_in_miles) { select("*, ST_Buffer(uk_area, #{convert_miles_to_metres(radius_in_miles || 0)}) AS uk_area") }

  self.ignored_columns += %i[area centroid]

  def self.with_name(location)
    find_by(name: mapped_name(location))
  end

  def self.contain?(location)
    with_name(location).present?
  end

  def self.mapped_name(location)
    (MAPPED_LOCATIONS[location&.downcase].presence || location)&.downcase
  end

  def self.find_valid_for_location(location)
    polygon = with_name(location)
    if polygon.present? && polygon.uk_area.invalid_reason.nil?
      polygon
    end
  rescue RGeo::Error::InvalidGeometry
    nil
  end

  # Buffers the polygon's area by the given radius in metres and returns the resulting expanded area in geometry.
  # The "where & pick" approach is more efficient to retrieve a single computed value from the DB than loading the whole object.
  def buffered_geometry_area(radius_in_metres)
    wkb = self.class.where(id: id)
        .pick(Arel.sql("ST_AsBinary(ST_Buffer(uk_area::geometry,#{radius_in_metres}))"))
    # Has to use this or the returned geometry gets a SRID: 0 even when set in the DB as 27700
    GeoFactories::FACTORY_27700.parse_wkb(wkb) if wkb
  rescue RGeo::Error::InvalidGeometry
    nil
  end
end
