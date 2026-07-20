require "rails_helper"

RSpec.describe OnsDataImport::ImportCities do
  before do
    stub_request(:get, /Major_Towns_and_Cities_Dec_2015_Boundaries_V2_2022/)
      .to_return(
        { status: 200, body: file_fixture("ons_cities_geojson.json").read, headers: { content_type: "application/json" } },
        { status: 200, body: { features: [] }.to_json, headers: { content_type: "application/json" } },
      )
    described_class.call
  end

  describe "#call" do
    let(:lincoln) { LocationPolygon.find_by(name: "lincoln") }
    let(:atlantis) { LocationPolygon.find_by(name: "atlantis") }

    it "creates a LocationPolygon for Lincoln" do
      expect(lincoln.area.to_s).to eq("POLYGON ((0.0 0.0, 1.0 1.0, 1.0 -1.0, 0.0 0.0))")
    end

    it "does not create a LocationPolygon for Atlantis" do
      expect(atlantis).to be_nil
    end
  end
end
