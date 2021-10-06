require "rails_helper"

RSpec.describe OnsDataImport::ImportCounties do
  subject { described_class.new }

  let(:response1) { double(success?: true, to_s: file_fixture("ons_counties_geojson.json").read) }
  let(:response2) { double(success?: true, to_s: { features: [] }.to_json) }

  before do
    allow(HTTParty).to receive(:get)
      .with(/Counties_and_Unitary_Authorities_April_2019_EW_BUC_v2/)
      .and_return(response1, response2)
  end

  describe "#call" do
    it "creates a LocationPolygon for Lincolnshire" do
      subject.call
      lincolnshire = LocationPolygon.find_by(name: "lincolnshire")
      expect(lincolnshire.area.to_s).to eq("POLYGON ((0.0 0.0, 1.0 1.0, 1.0 -1.0, 0.0 0.0))")
    end

    it "does not create a LocationPolygon for Nowhereshire" do
      expect(LocationPolygon.where(name: "Nowhereshire")).to be_empty
    end
  end
end
