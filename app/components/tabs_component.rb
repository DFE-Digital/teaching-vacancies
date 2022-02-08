class TabsComponent < ApplicationComponent
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
