class MapComponent < GovukComponent::Base
  def initialize(items: [], render: true, zoom: 13, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @render = render
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
