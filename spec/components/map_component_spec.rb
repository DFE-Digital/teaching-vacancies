require "rails_helper"

RSpec.describe MapComponent, type: :component do
  subject! { render_inline(described_class.new(**kwargs)) }

  let(:kwargs) { { markers: markers } }
  let(:markers) do
    [
      {
        id: "id",
        parent_id: "parent",
        geopoint: "GeoJSONPoint",
      },
    ]
  end

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "renders map component" do
    it "renders a list of markers" do
      expect(page).to have_css("div[data-map-target='marker'][data-point=GeoJSONPoint]")
      expect(page).to have_css("div[data-id='id']")
      expect(page).to have_css("div[data-parent-id='parent']")
    end

    it "renders a map container" do
      expect(page).to have_css(".map-component__map")
    end
  end
end
