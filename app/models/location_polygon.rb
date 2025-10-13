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

  def self.find_valid_for_location(location)
    polygon = with_name(location)
    if polygon.present? && polygon.area.invalid_reason.nil?
      polygon
    end
  rescue RGeo::Error::InvalidGeometry
    nil
  end

  # Memoized factory for parsing WKB into geometry objects
  def self.cartesian_factory_4326
    @cartesian_factory_4326 ||= RGeo::Cartesian.factory(srid: 4326)
  end

  # Buffers the polygon's area by the given radius in metres and returns the resulting expanded area in geometry.
  # Transformations are needed since the original area is a geographic type.
  #
  # The "where & pick" approach is more efficient to retrieve a single computed value from the DB than loading the whole object.
  #
  # Why buffering in SRID 3857 to then store it as SRID 4326?
  # Buffering is best done in a projected coordinate system (like 3857) for accuracy, as it buffers in metres instead of degrees).
  # After buffering, we transform to SRID: 4326 (lat/lon data). As we're doing spatial queries on this data, 4326 is more appropriate.
  def buffered_geometry_area(radius_in_metres)
    wkb = self.class
      .where(id: id)
      .pick(
        Arel.sql(
          "ST_AsBinary(
             ST_Transform(
               ST_Buffer(
                 ST_Transform(area::geometry, 3857),
                 #{radius_in_metres}
               ),
             4326)
           )",
        ),
      )
    return nil unless wkb

    self.class.cartesian_factory_4326.parse_wkb(wkb) # Has to use this or the returned geometry gets a SRID: 0 even when set in the DB as 4326
  rescue RGeo::Error::InvalidGeometry
    nil
  end
end
