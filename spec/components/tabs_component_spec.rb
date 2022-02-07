require "rails_helper"

RSpec.describe TabsComponent, type: :component do
  let(:kwargs) { {} }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when navigation items are defined" do
    subject! do
      render_inline(described_class.new(**kwargs)) do |dashboard|
        dashboard.navigation_item(item: "A dashboard item")
        dashboard.navigation_item(item: "Another dashboard item")
      end
    end

    it "renders the navigation items" do
      expect(page).to have_css("div", class: "tabs-component") do |dashboard|
        expect(dashboard).to have_css("div", class: "tabs-component-navigation__nav") do |items|
          expect(items).to have_css("li", class: "tabs-component-navigation__item", text: "A dashboard item")
          expect(items).to have_css("li", class: "tabs-component-navigation__item", text: "Another dashboard item")
        end
      end
    end
  end
end
