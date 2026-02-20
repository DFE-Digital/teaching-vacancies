class LocationPolygon < ApplicationRecord
  extend DistanceHelper

  # British National Grid SRID (EPSG:27700) is a projected coordinate system used for mapping in Great Britain.
  # It provides coordinates in meters, which is useful for distance calculations, which we need
  # for radius-based searches.
  # It is significantly more accurate for distance calculations in Great Britain that EPSG:3857 (Web Mercator).
  # EPSG:3857 distort distances and areas, especially as you move away from the equator. What would cause a multiplier
  # between 1.5x and 1.7x for radius/buffer distances in our case to get the matches we would expect.
  BRITISH_NATIONAL_GRID_SRID = 27700 # rubocop:disable Style/NumericLiterals

  validates :name, presence: true

  # This field is still set in the SQL to build these objects, but it is completely
  # ignored in the rest of the codebase.
  self.ignored_columns += [:location_type]

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

  # Buffers the polygon's area by the given radius in metres and returns the resulting expanded area in geometry.
  # Transformations are needed since the original area is a geographic type.
  #
  # The "where & pick" approach is more efficient to retrieve a single computed value from the DB than loading the whole object.
  #
  # Why buffering in British National Grid SRID (27700) to then store it as SRID 4326?
  # Buffering is best done in a projected coordinate system as it buffers in metres instead of degrees).
  # After buffering, we transform to SRID: 4326 (lat/lon data). As we're doing spatial queries on this data, 4326 is more appropriate.
  def buffered_geometry_area(radius_in_metres)
    wkb = self.class.where(id: id).pick(
      Arel.sql(
        "ST_AsBinary(
            ST_Transform(
              ST_Buffer(
                ST_Transform(area::geometry, #{BRITISH_NATIONAL_GRID_SRID}),
                #{radius_in_metres}
              ),
            4326)
          )",
      ),
    )
    return nil unless wkb

    # Has to use this or the returned geometry gets a SRID: 0 even when set in the DB as 4326
    RGeo::Cartesian.factory(srid: 4326).parse_wkb(wkb)
  rescue RGeo::Error::InvalidGeometry
    nil
  end

  # Buffers the polygon's area by the given radius in metres and returns the resulting expanded area in geometry.
  # The "where & pick" approach is more efficient to retrieve a single computed value from the DB than loading the whole object.
  def buffered_geometry_uk_area(radius_in_metres)
    wkb = self.class.where(id: id)
              .pick(Arel.sql("ST_AsBinary(ST_Buffer(uk_area::geometry,#{radius_in_metres}))"))
    # Has to use this or the returned geometry gets a SRID: 0 even when set in the DB as 27700
    GeoFactories::FACTORY_27700.parse_wkb(wkb) if wkb
  end
end
