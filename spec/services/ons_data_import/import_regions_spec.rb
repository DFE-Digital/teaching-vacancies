require "rails_helper"

RSpec.describe OnsDataImport::ImportRegions do
  let(:city_response) { double(body: JSON.parse(file_fixture("ons_regions_geojson.json").read)) }
  let(:response2) { double(body: { "features" => [] }) }

  # faraday doesn't work with VerifiedDoubles as it creates methlods dynamically
  # rubocop:disable RSpec/VerifiedDoubles
  let(:faraday) { double(Faraday) }
  # rubocop:enable RSpec/VerifiedDoubles

  before do
    allow(Faraday).to receive(:new)
      .and_return(faraday)
    allow(faraday).to receive(:get)
      .with(/Regions_December_2025_Boundaries_EN_BSC/, hash_including("outSR" => "4326"))
      .and_return(city_response, response2)
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
