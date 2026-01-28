require "rails_helper"

RSpec.describe OnsDataImport::ImportCounties do
  let(:response1) { double(success?: true, to_s: file_fixture("ons_counties_geojson.json").read) }
  let(:response2) { double(success?: true, to_s: { features: [] }.to_json) }

  # sadly this can't be a VCR test because the resultant download file is 118Mb
  # which is impractical to even cut-down
  before do
    allow(HTTParty).to receive(:get)
      .with(/Counties_and_Unitary_Authorities_April_2019_Boundaries_EW_BFC_2022/)
      .and_return(response1, response2)
    described_class.call
  end

  describe "#call" do
    let(:lincolnshire) { LocationPolygon.find_by(name: "lincolnshire") }
    let(:conwy) { LocationPolygon.find_by(name: "conwy") }

    it "creates a LocationPolygon for Lincolnshire" do
      expect(lincolnshire.area.to_s).to eq("POLYGON ((0.0 0.0, 1.0 1.0, 1.0 -1.0, 0.0 0.0))")
      expect(lincolnshire.location_type).to eq("counties")
    end

    it "does not create a LocationPolygon for Conwy as it is welsh" do
      expect(conwy).to be_nil
    end
  end
end
