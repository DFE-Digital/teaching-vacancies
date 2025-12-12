# frozen_string_literal: true

class GeoFactories
  EPSG_2700_PROJ4 = "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +units=m +no_defs +type=crs"

  PROJ4_4326 = "+proj=longlat +datum=WGS84 +no_defs +type=crs"

  WGS84_WKT = <<~WKT
    GEOGCS["WGS 84",
      DATUM["WGS_1984",
        SPHEROID["WGS 84",6378137,298.257223563,
          AUTHORITY["EPSG","7030"]],
        AUTHORITY["EPSG","6326"]],
      PRIMEM["Greenwich",0,
        AUTHORITY["EPSG","8901"]],
      UNIT["degree",0.01745329251994328,
        AUTHORITY["EPSG","9122"]],
      AUTHORITY["EPSG","4326"]]
  WKT

  WKT_27700 = <<~WKT
    PROJCS["OSGB36 / British National Grid",
        GEOGCS["OSGB36",
            DATUM["Ordnance_Survey_of_Great_Britain_1936",
                SPHEROID["Airy 1830",6377563.396,299.3249646,
                    AUTHORITY["EPSG","7001"]],
                AUTHORITY["EPSG","6277"]],
            PRIMEM["Greenwich",0,
                AUTHORITY["EPSG","8901"]],
            UNIT["degree",0.0174532925199433,
                AUTHORITY["EPSG","9122"]],
            AUTHORITY["EPSG","4277"]],
        PROJECTION["Transverse_Mercator"],
        PARAMETER["latitude_of_origin",49],
        PARAMETER["central_meridian",-2],
        PARAMETER["scale_factor",0.9996012717],
        PARAMETER["false_easting",400000],
        PARAMETER["false_northing",-100000],
        UNIT["metre",1,
            AUTHORITY["EPSG","9001"]],
        AXIS["Easting",EAST],
        AXIS["Northing",NORTH],
        AUTHORITY["EPSG","27700"]]
  WKT

  FACTORY_4326 = RGeo::Geographic.spherical_factory(srid: 4326, proj4: PROJ4_4326, coord_sys: WGS84_WKT)

  # British National Grid SRID (EPSG:27700) is a projected coordinate system used for mapping in Great Britain.
  # It provides coordinates in meters, which is useful for distance calculations, which we need
  # for radius-based searches.
  # It is significantly more accurate for distance calculations in Great Britain that EPSG:3857 (Web Mercator).
  # EPSG:3857 distort distances and areas, especially as you move away from the equator. What would cause a multiplier
  # between 1.5x and 1.7x for radius/buffer distances in our case to get the matches we would expect.
  BRITISH_NATIONAL_GRID_SRID = 27700 # rubocop:disable Style/NumericLiterals

  FACTORY_27700 = RGeo::Cartesian.preferred_factory(srid: BRITISH_NATIONAL_GRID_SRID, proj4: EPSG_2700_PROJ4, coord_sys: WKT_27700)

  class << self
    def convert_wgs84_to_sr27700(geopoint)
      RGeo::Feature.cast(geopoint,
                         factory: FACTORY_27700, project: true)
    end

    def convert_sr27700_to_wgs84(geopoint)
      RGeo::Feature.cast(geopoint,
                         factory: FACTORY_4326, project: true)
    end
  end
end
