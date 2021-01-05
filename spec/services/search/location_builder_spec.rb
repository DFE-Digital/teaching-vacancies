require "rails_helper"

RSpec.shared_examples "a search using polygons" do |options|
  it "sets the correct attributes" do
    expect(subject.location_category).to eq(options&.dig(:location)&.presence || location_polygon.name)
    expect(subject.location_polygon).to eq(location_polygon)
    expect(subject.location_filter).to eq({})
    expect(subject.buffer_radius).to eq(buffer_radius)
  end
end

RSpec.describe Search::LocationBuilder do
  subject { described_class.new(location, radius, location_category, buffer_radius) }

  let(:location) { nil }
  let(:location_category) { nil }
  let(:point_location) { "SW1A 1AA" }
  let(:radius) { nil }
  let(:buffer_radius) { nil }
  let!(:location_polygon) { create(:location_polygon, name: "london") }

  describe "#initialize" do
    context "when a polygonable location is specified" do
      context "by location parameter" do
        let(:location) { location_polygon.name }

        it_behaves_like "a search using polygons"
      end

      context "by location_category parameter" do
        let(:location_category) { location_polygon.name }

        it_behaves_like "a search using polygons"
      end

      context "by location_category parameter and location parameter" do
        let(:location) { location_polygon.name }
        let(:location_category) { location_polygon.name }

        it_behaves_like "a search using polygons"
      end

      context "and polygon coordinate lookup fails (for large areas)" do
        let(:location_category) { "North West" }

        it "missing polygon is true" do
          expect(subject.location_category).to eq "North West"
          expect(subject.location_polygon).to be nil
          expect(subject.location_filter).to eq({})
          expect(subject.missing_polygon).to be true
        end
      end

      context "when a buffer radius is present" do
        let(:location_category) { location_polygon.name }
        let(:buffer_radius) { "5" }

        it_behaves_like "a search using polygons"
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
          expect(subject.location_category).to be nil
          expect(subject.location_polygon).to be nil
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
          expect(subject.location_category).to be nil
          expect(subject.location_polygon).to be nil
          expect(subject.location_filter).to eq({
            point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
            radius: expected_radius,
          })
        end
      end
    end
  end
end
