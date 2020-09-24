require 'geokit'

class PolygonCentroidFinder
  include Geokit

  attr_reader :centroid

  def initialize(location_polygon)
    @location_polygon = location_polygon
    @centroid = get_centroid
  end

private

  def get_centroid
    Polygon.new(get_latlngs).centroid
  end

  def get_latlngs
    latlngs = []
    @location_polygon.points.each do |point|
      latlngs.push LatLng.new(point.first, point.second)
    end
    latlngs
  end
end
