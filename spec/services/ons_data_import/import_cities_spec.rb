require "rails_helper"

RSpec.describe OnsDataImport::ImportCities do
  let(:city_response) { double(body: JSON.parse(file_fixture("ons_cities_geojson.json").read)) }
  let(:response2) { double(body: { "features" => [] }) }

  # faraday doesn't work with VerifiedDoubles as it creates methlods dynamically
  # rubocop:disable RSpec/VerifiedDoubles
  let(:faraday) { double(Faraday) }
  # rubocop:enable RSpec/VerifiedDoubles

  before do
    allow(Faraday).to receive(:new)
                        .and_return(faraday)
    allow(faraday).to receive(:get)
                        .with(/Major_Towns_and_Cities_Dec_2015_Boundaries_V2_2022/,
                              hash_including("outSR" => "4326"))
                        .and_return(city_response, response2)

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
