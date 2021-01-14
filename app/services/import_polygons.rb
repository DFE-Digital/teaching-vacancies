class ImportPolygons
  BUFFER_API_URL = "https://ons-inspire.esriuk.com/arcgis/rest/services/Utilities/Geometry/GeometryServer/buffer?".freeze
  URL_MAXIMUM_LENGTH = 2000

  include DistanceHelper

  attr_reader :location_type

  def initialize(location_type:)
    @location_type = location_type
  end

  def call
    response = HTTParty.get(LOCATION_POLYGON_SETTINGS[location_type][:boundary_api])

    response.fetch("features", []).each do |region_response|
      region_name = region_response.dig("attributes", LOCATION_POLYGON_SETTINGS[location_type][:name_key]).downcase

      next unless location_categories_include?(region_name)

      geometry_rings = region_response.dig("geometry", "rings")

      # The first ring is the outer boundary and tends to contain far more points than subsequent rings.
      # All subsequent rings within this outer ring are bodies of water (essentially exclusion rings) and
      # can therefore be dismissed.
      # Boundary should be visualised to check how it should be used.
      # If algolia searches by polygon are slow, these boundaries could be downsampled significantly.
      points = []
      geometry_rings[0].each do |point|
        # API returns coords in an unconventional lng,lat order
        # Coordinates rounded as they are stored as double precision floats which have a precision of
        # 15 decimal digits. All UK coordinates only have a maxium of 2 digits before decimal point.
        points.push(*point.reverse.map { |coord| coord.round(13) })
      end

      LocationPolygon.find_or_create_by(name: region_name, location_type: location_type.to_s)
                     .update(boundary: points, buffers: get_buffers(points))
    end
  end

  private

  def location_categories_include?(region_name)
    location_type == :regions && DOWNCASE_REGIONS.include?(region_name) ||
      location_type == :counties && DOWNCASE_COUNTIES.include?(region_name) ||
      location_type == :london_boroughs && DOWNCASE_BOROUGHS.include?(region_name) ||
      location_type == :cities && DOWNCASE_CITIES.include?(region_name)
  end

  def get_buffers(points)
    # ArcGIS API documentation: https://ons-inspire.esriuk.com/arcgis/sdk/rest/index.html#//02ss0000003z000000
    buffer_distances_in_miles = [5, 10, 15, 20, 25]
    buffered_boundaries = {}
    buffer_distances_in_miles.each do |distance|
      # convert 1D array, to 2D array for arcgis
      polygon_coords = points.each_slice(2).to_a
      response = HTTParty.get(buffer_api_endpoint(polygon_coords, convert_miles_to_metres(distance)))
      # Buffer coordinates are stored as a 1D array
      buffer_coords = response.dig("geometries", 0, "rings").flatten
      buffered_boundaries[distance.to_s] = buffer_coords
    end
    buffered_boundaries
  end

  def buffer_api_endpoint(coords, distance)
    geometries_param = {
      "geometryType" => "esriGeometryPolygon",
      "geometries" => [{ "rings" => [coords] }],
    }

    params = { "geometries" => geometries_param.to_s,
               "inSR" => "4326",
               "outSR" => "4326",
               "bufferSR" => "3857",
               "distances" => distance.to_s,
               "unit" => "",
               "unionResults" => "true",
               "geodesic" => "false",
               "f" => "json" }.to_param

    api_endpoint = BUFFER_API_URL + params

    if api_endpoint.length > URL_MAXIMUM_LENGTH
      # Reduce number of coordinates in order to have fewer than 2000 characters in request url
      condensed_coords = take_every_nth_coord(coords, 5)
      api_endpoint = buffer_api_endpoint(condensed_coords, distance)
    end

    api_endpoint
  end

  def take_every_nth_coord(coords, number)
    coords.each_with_index.map { |item, index| item if (index % number).zero? }.compact
  end
end
