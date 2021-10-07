require "rails_helper"

RSpec.describe OnsDataImport::ImportRegions do
  subject { described_class.new }

  let(:response1) { double(success?: true, to_s: file_fixture("ons_regions_geojson.json").read) }
  let(:response2) { double(success?: true, to_s: { features: [] }.to_json) }

  before do
    allow(HTTParty).to receive(:get)
      .with(/regions/)
      .and_return(response1, response2)
    subject.call
  end

  describe "#call" do
    let(:east_midlands) { LocationPolygon.find_by(name: "east midlands") }
    let(:mid_eastlands) { LocationPolygon.find_by(name: "mid eastlands") }

    it "creates a LocationPolygon for East Midlands" do
      expect(east_midlands.area.to_s).to eq("POLYGON ((0.0 0.0, 1.0 1.0, 1.0 -1.0, 0.0 0.0))")
      expect(east_midlands.location_type).to eq("regions")
    end

    it "does not create a LocationPolygon for Mid Eastlands" do
      expect(mid_eastlands).to be_nil
    end
  end
end
