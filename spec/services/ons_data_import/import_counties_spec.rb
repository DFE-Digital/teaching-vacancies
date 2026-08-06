require "rails_helper"

RSpec.describe OnsDataImport::ImportCounties do
  let(:response1) { double(body: JSON.parse(file_fixture("ons_counties_geojson.json").read)) }
  let(:response2) { double(body: { "features" => [] }) }

  # faraday doesn't work with VerifiedDoubles as it creates methlods dynamically
  # rubocop:disable RSpec/VerifiedDoubles
  let(:faraday) { double(Faraday) }
  # rubocop:enable RSpec/VerifiedDoubles

  before do
    allow(Faraday).to receive(:new)
                        .and_return(faraday)
    allow(faraday).to receive(:get)
                        .with(/Counties_and_Unitary_Authorities_December_2025_Boundaries_UK_BSC/, hash_including("outSR" => "4326"))
                        .and_return(response1, response2)

    described_class.call
  end

  describe "#call" do
    let(:lincolnshire) { LocationPolygon.find_by(name: "lincolnshire") }
    let(:conwy) { LocationPolygon.find_by(name: "conwy") }

    it "creates a LocationPolygon for Lincolnshire" do
      expect(lincolnshire.area.to_s).to eq("POLYGON ((0.0 0.0, 1.0 1.0, 1.0 -1.0, 0.0 0.0))")
    end

    it "does not create a LocationPolygon for Conwy as it is welsh" do
      expect(conwy).to be_nil
    end
  end
end
