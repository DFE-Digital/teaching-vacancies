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

  # The location polygon variant is untested
  # simplecov:disable
  def radius
    @polygon.nil? && @radius ? @radius : nil
  end
  # simplecov:enable

  def default_classes
    %w[map-component]
  end

  def render?
    @markers.any? { |marker| marker[:geopoint] }
  end
end
