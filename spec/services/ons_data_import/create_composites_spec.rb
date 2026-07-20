require "rails_helper"

RSpec.describe OnsDataImport::CreateComposites do
  let(:composite_locations) { { "bedfordshire" => ["Bedford", "Central Bedfordshire", "Luton"] } }
  # faraday doesn't work with VerifiedDoubles as it creates methods dynamically
  # rubocop:disable RSpec/VerifiedDoubles
  let(:faraday) { double(Faraday) }
  # rubocop:enable RSpec/VerifiedDoubles
  let(:city_response) { double(body: JSON.parse(file_fixture("ons_cities_geojson.json").read)) }
  let(:endtransmission) { double(body: { "features" => [] }) }
  let(:response2) { double(body: JSON.parse(file_fixture("ons_bedfordshire_geojson.json").read)) }

  before do
    stub_const("DOWNCASE_COMPOSITE_LOCATIONS", composite_locations)
  end

  describe "#call", :vcr do
    before do
      allow(Faraday).to receive(:new)
                          .and_return(faraday)
      allow(faraday).to receive(:get)
                          .with(/Major_Towns_and_Cities_Dec_2015_Boundaries_V2_2022/,
                                hash_including("outSR" => "4326"))
                          .and_return(city_response, endtransmission)
      allow(faraday).to receive(:get)
                          .with(/Counties_and_Unitary_Authorities_December_2025_Boundaries_UK_BSC/, hash_including("outSR" => "4326"))
                          .and_return(response2, endtransmission)
    end

    it "generates a composite polygon and its children" do
      expect { described_class.call }.to change(LocationPolygon, :count).by(4)
    end
  end
end
