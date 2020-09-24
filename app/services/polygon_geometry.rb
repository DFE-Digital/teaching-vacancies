require 'geokit'

class PolygonGeometry
  include Geokit

  attr_reader :centroid

  def initialize(location_polygon)
    @location_polygon = location_polygon
    @geokit_polygon = Polygon.new(get_latlngs)
    @centroid = @geokit_polygon.centroid
  end

  def get_buffer_polygon(location_polygon:, buffer_in_metres: 30_000)
    start_time = Time.zone.now
    @location_polygon = location_polygon
    @buffer_in_metres = buffer_in_metres

    # convert 1D array of lat, lng to 2D array of coordinates
    points = @location_polygon.points

    # JSON of polygon for ArcGIS to consume
    buffer_polygon = HTTParty.get(construct_buffer_api(points))

    # 1D array of polygon for Algolia to consume
    buffer_boundary = buffer_polygon['geometries'].first['rings'].flatten

    puts Time.zone.now - start_time
    [buffer_polygon, buffer_boundary]
  end

# binding.pry
# buffered_polygon = LocationPolygon.first.boundary

# # https://sampleserver6.arcgisonline.com/arcgis/rest/services/Utilities/Geometry/GeometryServer/relation?sr=4326&geometries1={"geometryType":"esriGeometryPoint","geometries":[{"x":-104.53,"y":34.74},{"x":-63.53,"y":10.23}]}&geometries2={"geometryType":"esriGeometryPolygon","geometries":[{"rings":[[[-105,34],[-104,34],[-104,35],[-105,35],[-105,34]]]}]}&relation=esriGeometryRelationWithin&relationParam=&f=html

# mid_time = Time.zone.now

# LocationPolygon.each do |polygon|
#   HTTParty.get(http://sampleserver6.arcgisonline.com/arcgis/rest/services/Utilities/Geometry/GeometryServer/relation?sr=4326&geometries1=%7B%22geometryType%22%3A%22esriGeometryPolygon%22%2C%22geometries%22%3A%5B%7B%22rings%22%3A%5B%5B%5B0%2C0%5D%2C%5B0%2C4%5D%2C%5B2%2C2%5D%2C%5B3%2C4%5D%2C%5B5%2C0%5D%2C%5B0%2C0%5D%5D%5D%7D%2C%7B%22rings%22%3A%5B%5B%5B0%2C4%5D%2C%5B3%2C4%5D%2C%5B6.72%2C3.42%5D%2C%5B4.34%2C2%5D%2C%5B0%2C4%5D%5D%5D%7D%5D%7D&geometries2=%7B%22geometryType%22%3A%22esriGeometryPolygon%22%2C%22geometries%22%3A%5B%7B%22rings%22%3A%5B%5B%5B3%2C4%5D%2C%5B6%2C72%2C3.42%5D%2C%5B4.34%2C2%5D%2C%5B3%2C4%5D%5D%5D%7D%2C%7B%22rings%22%3A%5B%5B%5B5%2C1%5D%2C%5B7%2C1%5D%2C%5B7%2C0%5D%2C%5B5%2C0%5D%2C%5B5%2C1%5D%5D%5D%7D%2C%7B%22rings%22%3A%5B%5B%5B1%2C1%5D%2C%5B1%2C2%5D%2C%5B2%2C1%5D%2C%5B1%2C1%5D%5D%5D%7D%2C%7B%22rings%22%3A%5B%5B%5B3%2C1%5D%2C%5B5%2C1%5D%2C%5B7%2C1%5D%2C%5B7%2C0%5D%2C%5B3%2C0%5D%2C%5B3%2C1%5D%5D%5D%7D%0D%0A%5D%7D&relation=esriGeometryRelationIntersection&relationParam=&f=html)
# end

# end_time = Time.zone.now
# duration = end_time - start_time
# puts duration

private

  def construct_buffer_api(points)
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
      api = construct_buffer_api(points)
    end

    api
  end

  def get_latlngs
    latlngs = []
    @location_polygon.points.each do |point|
      latlngs.push LatLng.new(point.first, point.second)
    end
    latlngs
  end
end
