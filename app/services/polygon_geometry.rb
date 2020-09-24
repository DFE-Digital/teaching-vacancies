require 'geokit'

class PolygonGeometry
  include Geokit

  attr_reader :centroid

  def initialize(location_polygon)
    @location_polygon = location_polygon
    @centroid = Polygon.new(get_latlngs(@location_polygon.points)).centroid
  end

  def find_nearby_polygons(buffer_in_metres)
    # This finds all LocationPolygons whose centroids are within a
    # vector buffer of the original polygon.
    buffered_polygon = get_buffered_polygon(buffer_in_metres)
    LocationPolygon.all.select do |location_polygon|
      next if location_polygon == @location_polygon

      latlng = LatLng.new(location_polygon.centroid.x, location_polygon.centroid.y)
      buffered_polygon.contains?(latlng)
    end
  end

  def get_buffered_polygon(buffer_in_metres)
    @buffer_in_metres = buffer_in_metres

    buffer_response = HTTParty.get(buffer_api(@location_polygon.points))
    latlngs = get_latlngs(buffer_response['geometries'].first['rings'].first)
    Polygon.new(latlngs)
  end

private

  def buffer_api(points)
    geometries_param = {
      'geometryType' => 'esriGeometryPolygon',
      'geometries' => [{ 'rings' => [points] }]
    }

    params = { 'geometries' => geometries_param.to_s,
               'inSR' => '4326',
               'outSR' => '4326',
               'bufferSR' => '3857',
               'distances' => @buffer_in_metres.to_s,
               'unit' => '',
               'unionResults' => 'true',
               'geodesic' => 'false',
               'f' => 'json' }.to_param

    buffer_endpoint = 'https://ons-inspire.esriuk.com/arcgis/rest/services/Utilities/Geometry/GeometryServer/buffer?'

    api = buffer_endpoint + params

    if api.length > 2000
      # Reduce number of coordinates in order to have fewer than 2000 characters in request url
      points = points.each_with_index
      .map { |item, index| item if (index % 5).zero? }
      .compact
      api = buffer_api(points)
    end

    api
  end

  def get_latlngs(points)
    latlngs = []
    points.each do |point|
      latlngs.push LatLng.new(point.first, point.second)
    end
    latlngs
  end
end
