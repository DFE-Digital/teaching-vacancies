require "rails_helper"

RSpec.describe OnsDataImport::ImportCities do
  subject { described_class.new }

  let(:response1) { double(success?: true, to_s: file_fixture("ons_cities_geojson.json").read) }
  let(:response2) { double(success?: true, to_s: { features: [] }.to_json) }

  before do
    allow(HTTParty).to receive(:get)
      .with(/Major_Towns_and_Cities_December_2015_Boundaries/)
      .and_return(response1, response2)
    subject.call
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
