class TabsComponent < ApplicationComponent
  renders_many :navigation_items, lambda { |text:, link:, active: false|
    tag.li class: "tabs-component-navigation__item" do
      active = true if current_page?(link)
      govuk_link_to text, link, class: "tabs-component-navigation__link", aria: { current: ("page" if active) }
    end
  }

  private

  def default_attributes
    { class: %w[tabs-component] }
  end
end
