require "rails_helper"

RSpec.describe NavbarComponent, type: :component do
  let(:kwargs) { {} }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when navigation items are defined" do
    subject! do
      render_inline(described_class.new(**kwargs)) do |navigation|
        navigation.item(link_text: "A nav item", align: :left, path: "/1")
        navigation.item(link_text: :spacer)
        navigation.item(link_text: "Another nav item", align: :right, path: "/2")
      end
    end

    it "renders the navigation items" do
      expect(page).to have_css("nav", class: "navbar-component") do |nav|
        expect(nav).to have_css("ul", class: "navbar-component__items") do |list|
          expect(list).to have_css("li", class: "navbar-component__navigation-item--left", text: "A nav item") do |item|
            expect(item).to have_css("a[href='/1']")
          end
          expect(list).to have_css("li", class: "navbar-component__items-spacer")
          expect(list).to have_css("li", class: "navbar-component__navigation-item--right", text: "Another nav item") do |item|
            expect(item).to have_css("a[href='/2']")
          end
        end
      end
    end
  end
end
