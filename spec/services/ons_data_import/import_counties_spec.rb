require "rails_helper"

RSpec.describe OnsDataImport::ImportCounties do
  # sadly this can't be a VCR test because the resultant download file is 118Mb
  # which is impractical to even cut-down
  before do
    stub_request(:get, /Counties_and_Unitary_Authorities_April_2019_Boundaries_EW_BFC_2022/)
      .to_return(
        { status: 200, body: file_fixture("ons_counties_geojson.json").read },
        { status: 200, body: { features: [] }.to_json },
      )
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
