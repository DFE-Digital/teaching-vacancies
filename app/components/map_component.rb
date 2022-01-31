class MapComponent < GovukComponent::Base
  def initialize(items: [], render: true, show_map: true, zoom: 13, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @render = render
    @show_map = show_map
    @items = items
    @zoom = zoom
  end

  def render?
    @render
  end

  private

  def default_classes
    %w[map-component]
  end
end
