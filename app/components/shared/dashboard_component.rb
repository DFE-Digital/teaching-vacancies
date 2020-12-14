class Shared::DashboardComponent < ViewComponent::Base
  attr_accessor :heading, :navigation_items, :panel, :link

  def initialize(heading:, navigation_items:, panel:, link:)
    @heading = heading
    @navigation_items = navigation_items
    @panel = panel
    @link = link
  end

  def display_actions
    @panel || @link
  end
end
