require "rails_helper"

RSpec.describe TabsComponent, type: :component do
  let(:kwargs) { {} }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when navigation items are defined" do
    subject! do
      render_inline(described_class.new(**kwargs)) do |tabs|
        tabs.navigation_item(text: "A dashboard item", link: "/item", active: true)
        tabs.navigation_item(text: "Another dashboard item", link: "/another-item", active: false)
      end
    end

    it "renders the navigation items" do
      expect(page).to have_css("div", class: "tabs-component") do |tabs|
        expect(tabs).to have_css("li", class: "tabs-component-navigation__item", text: "A dashboard item") do |item|
          expect(item).to have_link("A dashboard item", href: "/item", class: "tabs-component-navigation__link")
          expect(item).to have_xpath("//a[@aria-current=\"page\"]")
        end
        expect(tabs).to have_css("li", class: "tabs-component-navigation__item", text: "Another dashboard item") do |item|
          expect(item).to have_link("Another dashboard item", href: "/another-item", class: "tabs-component-navigation__link")
        end
      end
    end
  end
end
