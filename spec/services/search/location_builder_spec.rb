require "rails_helper"

RSpec.shared_examples "a search using polygons" do
  it "sets the correct attributes" do
    expect(subject.polygon_boundaries).to eq(location_polygon.polygons["polygons"])
    expect(subject.location_filter).to eq({})
    expect(subject.buffer_radius).to eq(buffer_radius)
  end
end

RSpec.describe Search::LocationBuilder do
  subject { described_class.new(location, radius, buffer_radius) }

  let(:location) { nil }
  let(:point_location) { "SW1A 1AA" }
  let(:radius) { nil }
  let(:buffer_radius) { nil }
  let!(:location_polygon) { create(:location_polygon, name: "london") }

  describe "#initialize" do
    context "when a polygonable location is specified" do
      let(:location) { location_polygon.name }

      it_behaves_like "a search using polygons"

      context "when a buffer radius is present" do
        let(:location) { location_polygon.name }
        let(:buffer_radius) { "5" }

        it "sets the correct attributes" do
          expect(subject.location).to eq(location_polygon.name)
          expect(subject.polygon_boundaries).to eq(location_polygon.buffers["5"])
          expect(subject.location_filter).to eq({})
          expect(subject.buffer_radius).to eq(buffer_radius)
        end
      end
    end

    context "when a composite location is specified" do
      let(:location) { "Bedfordshire" }

      before do
        create(:location_polygon,
               name: "bedford",
               location_type: "counties",
               polygons: { "polygons" => [[1, 2]] },
               buffers: { "5" => [[9, 10], [11, 12]], "10" => [[1, 2]] })
        create(:location_polygon,
               name: "central bedfordshire",
               location_type: "counties",
               polygons: { "polygons" => [[3, 4]] },
               buffers: { "5" => [[13, 14]], "10" => [[1, 2]] })
        create(:location_polygon,
               name: "luton",
               location_type: "counties",
               polygons: { "polygons" => [[5, 6], [7, 8]] },
               buffers: { "5" => [[15, 16]], "10" => [[1, 2]] })
      end

      it "sets the correct attributes" do
        expect(subject.location).to eq(location)
        expect(subject.polygon_boundaries).to contain_exactly([1, 2], [3, 4], [5, 6], [7, 8])
        expect(subject.location_filter).to eq({})
        expect(subject.buffer_radius).to eq(buffer_radius)
      end

      context "when a buffer radius is present" do
        let(:buffer_radius) { "5" }

        it "sets the correct attributes" do
          expect(subject.location).to eq(location)
          expect(subject.polygon_boundaries).to contain_exactly([9, 10], [11, 12], [13, 14], [15, 16])
          expect(subject.location_filter).to eq({})
          expect(subject.buffer_radius).to eq(buffer_radius)
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
      context "and no radius specified" do
        let(:location) { point_location }
        let(:radius) { 10 }
        let(:expected_radius) { 16_093 }

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
        let(:expected_radius) { 48_280 }

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
