require "rails_helper"

RSpec.describe MapComponent, type: :component do
  let(:items) { [{ links: [{ text: "link text 1", url: "/link-url-1", id: 1 }] }] }
  let(:kwargs) { { items: items, show_map: true, zoom: 10 } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "renders map component" do
    it "that has correct data attributes" do
      component = page.find(".map-component")

      config = component["data-config"]
      expect(config).to eq(items.to_json)

      zoom = component["data-zoom"]
      expect(zoom).to eq("10")
    end

    it "displays a list of marker links" do
      expect(page).to have_css("ol") do |markers|
        expect(markers).to have_css("li") do |marker|
          expect(marker).to have_css("a[href='/link-url-1']", text: "link text 1")
        end
      end
    end

    it "renders a map container" do
      expect(page).to have_css(".map-component__map")
    end
  end
end
