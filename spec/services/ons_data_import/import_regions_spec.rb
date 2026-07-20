require "rails_helper"

RSpec.describe OnsDataImport::ImportRegions do
  before do
    stub_request(:get, /Regions_December_2025_Boundaries_EN_BSC/)
      .to_return(
        { status: 200, body: file_fixture("ons_regions_geojson.json").read, headers: { content_type: "application/json" } },
        { status: 200, body: { features: [] }.to_json, headers: { content_type: "application/json" } },
      )
    described_class.call
  end

  describe "#call" do
    let(:east_midlands) { LocationPolygon.find_by(name: "east midlands") }
    let(:mid_eastlands) { LocationPolygon.find_by(name: "mid eastlands") }

    it "creates a LocationPolygon for East Midlands" do
      expect(east_midlands.area.to_s).to eq("POLYGON ((0.0 0.0, 1.0 1.0, 1.0 -1.0, 0.0 0.0))")
    end

    it "does not create a LocationPolygon for Mid Eastlands" do
      expect(mid_eastlands).to be_nil
    end
  end
end
