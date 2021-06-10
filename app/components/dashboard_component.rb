class DashboardComponent < GovukComponent::Base
  attr_reader :heading, :link

  def initialize(heading:, link: nil, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

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
    %w[dashboard-component]
  end
end
