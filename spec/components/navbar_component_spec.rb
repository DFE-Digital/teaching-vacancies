require "rails_helper"

RSpec.describe NavbarComponent, type: :component do
  let(:kwargs) { {} }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when navigation items are defined" do
    subject! do
      render_inline(described_class.new(**kwargs)) do |navigation|
        navigation.item(link_text: "A nav item", align: :left, path: "/")
        navigation.item(link_text: :spacer)
        navigation.item(link_text: "Another nav item", align: :right, path: "/")
      end
    end

    it "renders the navigation items" do
      expect(page).to have_css("nav", class: "navbar-component") do |navigation|
        expect(navigation).to have_css("ul", class: "navbar-component__items") do |items|
          expect(items).to have_css("li", class: "navbar-component__navigation-item--left", text: "A nav item")
          expect(items).to have_css("li", class: "navbar-component__items-spacer")
          expect(items).to have_css("li", class: "navbar-component__navigation-item--right", text: "Another nav item")
        end
      end
    end
  end
end
