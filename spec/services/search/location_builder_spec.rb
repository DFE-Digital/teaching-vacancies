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
    before do
      stub_const("Search::LocationBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES", 32)
      stub_const("Search::LocationBuilder::DEFAULT_BUFFER_FOR_POLYGON_SEARCHES", 56)
    end

    context "when a polygonable location is specified" do
      let(:location) { location_polygon.name }

      it_behaves_like "a search using polygons"

      context "when the radius is the same as DEFAULT_BUFFER_FOR_POLYGON_SEARCHES" do
        before do
          stub_const("Search::LocationBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES", 32)
          stub_const("Search::LocationBuilder::DEFAULT_BUFFER_FOR_POLYGON_SEARCHES", 56)
        end

        let(:radius) { 56 }

        it "preserves the radius attribute" do
          expect(subject.radius).to eq(radius)
        end
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
      let(:radius_in_metres) { 1_609 * expected_radius }
      let(:location) { point_location }

      context "and no radius specified" do
        let(:radius) { nil }
        let(:expected_radius) { 32 }

        it "sets radius attribute, and location filter around the location, with the default radius for point location searches" do
          expect(subject.polygon_boundaries).to be_nil
          expect(subject.location_filter).to eq({
            point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
            radius: radius_in_metres,
          })
          expect(subject.radius).to eq(expected_radius)
        end
      end

      context "and radius specified" do
        let(:radius) { 30 }
        let(:expected_radius) { 30 }

        it "sets radius attribute, and location filter around the location, with the specified radius" do
          expect(subject.polygon_boundaries).to be_nil
          expect(subject.location_filter).to eq({
            point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
            radius: radius_in_metres,
          })
          expect(subject.radius).to eq(expected_radius)
        end

        context "when the radius is the same as DEFAULT_BUFFER_FOR_POLYGON_SEARCHES" do
          let(:radius) { 56 }
          let(:expected_radius) { 32 }

          it "sets radius attribute, and location filter around the location, with the default radius for point location searches" do
            expect(subject.polygon_boundaries).to be_nil
            expect(subject.location_filter).to eq({
              point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
              radius: radius_in_metres,
            })
            expect(subject.radius).to eq(expected_radius)
          end
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
