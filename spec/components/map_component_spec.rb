require "rails_helper"

RSpec.describe MapComponent, type: :component do
  let(:kwargs) { { markers: markers, zoom: 10 } }
  let(:markers) do
    [
      {
        geopoint: double("geopoint", lat: 1, lon: 2),
        heading: "marker_heading",
        description: "marker_description",
        address: "marker_address",
      },
    ]
  end

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "renders map component" do
    it "that has correct data attributes" do
      component = page.find(".map-component")
      expect(component["data-zoom"]).to eq("10")
    end

    it "renders a list of markers" do
      expect(page).to have_content "marker_heading"
      expect(page).to have_content "marker_description"
      expect(page).to have_content "marker_address"
      expect(page).to have_selector("div[data-map-target='marker'][data-lat=1][data-lon=2]")
    end

    it "renders a map container" do
      expect(page).to have_css(".map-component__map")
    end
  end
end
