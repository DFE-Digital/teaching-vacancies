class MapComponent < ApplicationComponent
  def initialize(markers:, marker: {}, polygon: nil, point: nil, radius: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @markers = markers
    @marker = marker
    @polygon = polygon
    @point = point
    @radius = radius
  end

  private

  def radius
    @polygon.nil? && @radius ? @radius : nil
  end

  def default_attributes
    { class: %w[map-component] }
  end

  def render?
    @markers.any? { |marker| marker[:geopoint] }
  end
end
