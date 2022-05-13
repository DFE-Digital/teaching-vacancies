class MapComponent < GovukComponent::Base
  def initialize(markers:, marker_type: nil, polygon: nil, point: nil, radius: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @markers = markers
    @marker_type = marker_type
    @polygon = polygon
    @point = point
    @radius = radius
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
