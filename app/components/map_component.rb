class MapComponent < GovukComponent::Base
  def initialize(markers:, polygon: nil, point: nil, radius: nil, zoom: 13, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @markers = markers
    @zoom = zoom
    @polygon = polygon
    @radius = radius
    @point = point
  end

  private

  def radius
    @polygon.nil? && @radius ? @radius : nil
  end

  def default_classes
    %w[map-component]
  end

  def show_map?
    @markers.any? { |marker| marker[:geopoint] }
  end
end
