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

      # If algolia searches by polygon are slow, (some of) these boundaries could be downsampled significantly.

      ring_index = if api_location_type == :counties
                     DOWNCASE_COUNTIES_WITH_RING_INDICES[location_name]
                   else
                     0
                   end

      points = []
      geometry_rings[ring_index].each do |point|
        # API returns coords in an unconventional lng,lat order
        # Coordinates rounded as they are stored as double precision floats which have a precision of
        # 15 decimal digits. All UK coordinates only have a maximum of 2 digits before decimal point.
        points.push(*point.reverse.map { |coord| coord.round(13) })
      end

      human_friendly_location_type = LOCATIONS_WITH_MAPPING_TO_HUMAN_FRIENDLY_LOCATION_TYPES[location_name] || api_location_type.to_s

      location_polygon = LocationPolygon.find_or_create_by(name: location_name, location_type: human_friendly_location_type)

      # Skip API call if the points have not changed since last time we used them to calculate the buffers.
      location_polygon.update(boundary: points, buffers: get_buffers(points)) unless points == location_polygon.boundary
    end
  end

  private

  def location_in_scope?
    api_location_type == :regions && DOWNCASE_ONS_REGIONS.include?(location_name) ||
      api_location_type == :counties && DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES.include?(location_name) ||
      api_location_type == :cities && DOWNCASE_ONS_CITIES.include?(location_name)
  end

  def get_buffers(points)
    buffered_boundaries = {}
    BUFFER_DISTANCES_IN_MILES.each do |distance|
      # convert 1D array to 2D array for arcgis
      polygon_coords = points.each_slice(2).to_a
      response = HTTParty.get(buffer_api_endpoint(polygon_coords, convert_miles_to_metres(distance)))
      # Buffer coordinates are stored as a 1D array
      buffer_coords = response.dig("geometries", 0, "rings").flatten
      buffered_boundaries[distance.to_s] = buffer_coords
    end
    buffered_boundaries
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
