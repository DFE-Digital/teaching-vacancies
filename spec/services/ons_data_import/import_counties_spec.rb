require "rails_helper"

RSpec.describe OnsDataImport::ImportCounties do
  subject { described_class.new }

  let(:response1) { double(success?: true, to_s: file_fixture("ons_counties_geojson.json").read) }
  let(:response2) { double(success?: true, to_s: { features: [] }.to_json) }

  before do
    allow(HTTParty).to receive(:get)
      .with(/Counties_and_Unitary_Authorities_April_2019_EW_BUC_v2/)
      .and_return(response1, response2)
    subject.call
  end

  describe "#call" do
    let(:lincolnshire) { LocationPolygon.find_by(name: "lincolnshire") }
    let(:nowhereshire) { LocationPolygon.find_by(name: "nowhereshire") }

    it "creates a LocationPolygon for Lincolnshire" do
      expect(lincolnshire.area.to_s).to eq("POLYGON ((0.0 0.0, 1.0 1.0, 1.0 -1.0, 0.0 0.0))")
      expect(lincolnshire.location_type).to eq("counties")
    end

    it "does not create a LocationPolygon for Nowhereshire" do
      expect(nowhereshire).to be_nil
    end
  end
end
