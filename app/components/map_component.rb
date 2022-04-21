class MapComponent < GovukComponent::Base
  def initialize(markers:, zoom: 13, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @markers = markers
    @zoom = zoom
  end

  private

  def default_classes
    %w[map-component]
  end

  def show_map?
    @markers.any? { |marker| marker[:geopoint] }
  end
end
