class DashboardComponent < GovukComponent::Base
  attr_reader :heading, :link

  def initialize(background: nil, heading: nil, link: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @background = background
    @heading = heading
    @link = link
  end

  renders_many :navigation_items, lambda { |item:|
    tag.li class: "dashboard-component-navigation__item" do
      item
    end
  }

  private

  def default_classes
    %w[dashboard-component].tap do |applied_classes|
      applied_classes.push("dashboard-component--background") if @background
    end
  end
end
