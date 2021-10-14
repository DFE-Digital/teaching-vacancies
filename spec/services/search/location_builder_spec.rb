require "rails_helper"

RSpec.shared_examples "a search using polygons" do
  it "sets the correct attributes" do
    buffered_polygon = LocationPolygon.buffered(radius).find_by(name: location_polygon.name)
    expect(subject.polygon_boundaries).to eq(buffered_polygon.to_algolia_polygons)
    expect(subject.location_filter).to eq({})
    expect(subject.radius).to eq(radius)
  end
end

RSpec.describe Search::LocationBuilder do
  subject { described_class.new(location, radius) }

  let(:location) { nil }
  let(:point_location) { "SW1A 1AA" }
  let(:radius) { 10 }
  let!(:location_polygon) { create(:location_polygon, name: "london") }

  describe "#initialize" do
    context "when a polygonable location is specified" do
      let(:location) { location_polygon.name }

      it_behaves_like "a search using polygons"
    end

    context "when a composite location is specified" do
      let(:location) { "Bedfordshire" }

      before do
        create(:location_polygon,
               name: "bedford",
               location_type: "counties")
        create(:location_polygon,
               name: "central bedfordshire",
               location_type: "counties")
        create(:location_polygon,
               name: "luton",
               location_type: "counties")
      end

      it "sets the correct attributes" do
        expect(subject.location).to eq(location)
        expect(subject.polygon_boundaries).to contain_exactly(
          *LocationPolygon.buffered(radius).where(name: [
            "bedford", "central bedfordshire", "luton"
          ]).flat_map(&:to_algolia_polygons),
        )
        expect(subject.location_filter).to eq({})
        expect(subject.radius).to eq(radius)
      end
    end

    context "when a mapped location is specified" do
      let(:location) { "Map this location" }

      before do
        allow(MAPPED_LOCATIONS).to receive(:[]).with(location.downcase).and_return(location_polygon.name)
      end

      it_behaves_like "a search using polygons", location: "Map this location"
    end

    context "when a non-polygonable location is specified" do
      context "and no radius specified" do
        let(:location) { point_location }
        let(:radius) { 10 }
        let(:expected_radius) { 16_090 }

        it "sets location filter around the location with the default radius" do
          expect(subject.polygon_boundaries).to be_nil
          expect(subject.location_filter).to eq({
            point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
            radius: expected_radius,
          })
        end
      end

      context "and radius specified" do
        let(:location) { point_location }
        let(:radius) { 30 }
        let(:expected_radius) { 48_270 }

        it "carries out geographical search around a coordinate location with the specified radius" do
          expect(subject.polygon_boundaries).to be_nil
          expect(subject.location_filter).to eq({
            point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
            radius: expected_radius,
          })
        end
      end
    end

    context "when a nationwide location is specified" do
      let(:location) { Search::LocationBuilder::NATIONWIDE_LOCATIONS.sample }

      it "does not set location filters" do
        expect(subject.location).to be nil
        expect(subject.polygon_boundaries).to be nil
        expect(subject.location_filter).to eq({})
      end
    end
  end
end
