class MapComponent < ViewComponent::Base
  def initialize(items:, render: true, zoom: 13)
    @render = render
    @items = items
    @zoom = zoom
  end

  def render?
    @render
  end
end
