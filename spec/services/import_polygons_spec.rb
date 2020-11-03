require "rails_helper"

RSpec.describe ImportPolygons do
  subject { described_class.new(location_type: location_type) }
  let(:endpoint) { LOCATION_POLYGON_SETTINGS[location_type][:api] }
  let(:response) { JSON.parse(file_fixture(file_name).read) }

  before do
    allow(HTTParty).to receive(:get).with(endpoint).and_return(response)
    subject.call
  end

  describe "#call" do
    context "when location type is regions" do
      let(:location_type) { :regions }
      let(:points) { [55.8110853660943, -2.0343575091738, 55.7647624900862, -1.9841097397706] }
      let(:file_name) { "ons_regions.json" }

      it "imports North East region" do
        expect(LocationPolygon.regions.first.name).to eq("north east")
      end

      it "does not import non-existent region" do
        expect(LocationPolygon.regions.count).to eq(1)
      end

      it "imports Nort East boundaries" do
        expect(LocationPolygon.regions.first.boundary).to eq(points)
      end
    end

    context "when location type is counties" do
      let(:location_type) { :counties }
      let(:points) { [52.0652732493605, 0.7031775640868, 52.0486871974891, 0.7162633765872] }
      let(:file_name) { "ons_counties.json" }

      it "imports Essex county" do
        expect(LocationPolygon.counties.first.name).to eq("essex")
      end

      it "does not import non-existent county" do
        expect(LocationPolygon.counties.count).to eq(1)
      end

      it "imports Essex boundaries" do
        expect(LocationPolygon.counties.first.boundary).to eq(points)
      end
    end

    context "when location type is london boroughs" do
      let(:location_type) { :london_boroughs }
      let(:points) { [51.5083356630733, 0.00456249603, 51.5051084208278, -0.0057105307948] }
      let(:file_name) { "ons_london_boroughs.json" }

      it "imports Tower Hamlets local authority" do
        expect(LocationPolygon.london_boroughs.first.name).to eq("tower hamlets")
      end

      it "does not import non-existent local authority" do
        expect(LocationPolygon.london_boroughs.count).to eq(1)
      end

      it "imports Tower Hamlets boundaries" do
        expect(LocationPolygon.london_boroughs.first.boundary).to eq(points)
      end
    end

    context "when location type is cities" do
      let(:location_type) { :cities }
      let(:points) { [51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145] }
      let(:file_name) { "ons_cities.json" }

      it "imports Bath city" do
        expect(LocationPolygon.cities.first.name).to eq("bath")
      end

      it "does not import non-existent city" do
        expect(LocationPolygon.cities.count).to eq(1)
      end

      it "imports Bath boundaries" do
        expect(LocationPolygon.cities.first.boundary).to eq(points)
      end
    end
  end
end
