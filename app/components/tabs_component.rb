class TabsComponent < GovukComponent::Base
  attr_reader :heading, :link

  def initialize(classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)
  end

  renders_many :navigation_items, lambda { |item:|
    tag.li class: "tabs-component-navigation__item" do
      item
    end
  }

  private

  def default_classes
    %w[tabs-component]
  end
end
