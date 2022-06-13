class MapComponent < ApplicationComponent
  def initialize(markers:, marker: {}, polygon: nil, point: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @markers = markers
    @marker = marker
    @polygon = polygon
    @point = point
  end

  private

  def default_classes
    %w[map-component]
  end

  def render?
    @markers.any? { |marker| marker[:geopoint] }
  end
end
