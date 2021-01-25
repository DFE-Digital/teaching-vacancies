class ImportPolygons
  BUFFER_API_URL = "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?".freeze
  BUFFER_DISTANCES_IN_MILES = [5, 10, 15, 20, 25].freeze
  URL_MAXIMUM_LENGTH = 33_000

  include DistanceHelper

  attr_reader :location_name, :api_location_type

  def initialize(api_location_type:)
    @api_location_type = api_location_type
  end

  def call
    response = JSON.parse(HTTParty.get(LOCATION_POLYGON_SETTINGS[api_location_type][:boundary_api]))

    response.fetch("features", []).each do |region_response|
      @location_name = region_response.dig("attributes", LOCATION_POLYGON_SETTINGS[api_location_type][:name_key]).downcase

      next unless location_in_scope?

      geometry_rings = region_response.dig("geometry", "rings")

      # When the ONS API returns multiple rings for a location, some of these are small islands or similar. Some of
      # these islands are inhabited and have a school on, and others do not. (E.g. Mersea Island in Essex, Hayling Island
      # in Hampshire, Sheppey Island in Kent, St Mary's in the Isles of Scilly.)
      #
      # If algolia searches by polygon are slow, (some of) these boundaries could be downsampled significantly.
      #
      # Store them in a hash because Postgres doesn't support multidimensional arrays of varying extents.

      polygons = []
      geometry_rings.each do |ring|
        polygon = []
        ring.each do |point|
          # API returns coords in an unconventional lng,lat order
          # Coordinates rounded as they are stored as double precision floats which have a precision of
          # 15 decimal digits. All UK coordinates only have a maximum of 2 digits before decimal point.
          polygon.push(*point.reverse.map { |coord| coord.round(13) })
        end
        polygons.push(polygon)
      end
      polygons_hash = { "polygons" => polygons }

      location_polygon = LocationPolygon.find_or_create_by(name: location_name)

      # Update location_type separately to reduce chance of creating duplicate LocationPolygons for the same location
      # when we change a location's location-type mapping.
      location_polygon.update(location_type: LOCATIONS_MAPPED_TO_HUMAN_FRIENDLY_TYPES[location_name])

      # Skip buffers API call if the points have not changed since last time we used them to calculate the buffers.
      location_polygon.update(polygons: polygons_hash, buffers: get_buffers(polygons)) unless polygons_hash == location_polygon.polygons
    end
  end

  private

  def location_in_scope?
    api_location_type == :regions && DOWNCASE_ONS_REGIONS.include?(location_name) ||
      api_location_type == :counties && DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES.include?(location_name) ||
      api_location_type == :cities && DOWNCASE_ONS_CITIES.include?(location_name)
  end

  def get_buffers(polygons)
    buffers = {}
    BUFFER_DISTANCES_IN_MILES.each do |distance|
      buffered_polygon_coords = []
      polygons.each do |polygon|
        # convert 1D array to 2D array for arcgis
        polygon_coords = polygon.each_slice(2).to_a
        response = HTTParty.get(buffer_api_endpoint(polygon_coords, convert_miles_to_metres(distance)))
        # Buffer coordinates are stored as a 1D array
        buffered_polygon_coords.push(response.dig("geometries", 0, "rings").flatten)
      end
      buffers[distance.to_s] = buffered_polygon_coords
    end
    buffers
  end

  def buffer_api_endpoint(coords, distance)
    # Documentation of ArcGIS API: https://developers.arcgis.com/rest/services-reference/buffer.htm

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
      # Reduce number of coordinates in order to have not too many characters in request url
      condensed_coords = take_every_nth_coord(coords, 5)
      api_endpoint = buffer_api_endpoint(condensed_coords, distance)
    end

    api_endpoint
  end

  def take_every_nth_coord(coords, number)
    coords.each_with_index.map { |item, index| item if (index % number).zero? }.compact
  end
end
