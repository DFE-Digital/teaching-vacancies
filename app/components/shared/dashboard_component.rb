class Shared::DashboardComponent < ViewComponent::Base
  attr_reader :heading, :navigation_items, :panel, :link

  def initialize(heading:, navigation_items: [], link: nil)
    @heading = heading
    @navigation_items = navigation_items
    @link = link
  end
end
