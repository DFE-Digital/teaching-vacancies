require "rails_helper"

RSpec.shared_examples "a search using polygons" do
  it "sets the correct attributes" do
    buffered_polygon = LocationPolygon.buffered(expected_radius).find_by(name: location_polygon.name)
    expect(subject.polygon.area).to eq(buffered_polygon.area)
    expect(subject.location_filter).to eq({})
    expect(subject.radius).to eq(expected_radius)
  end
end

RSpec.describe Search::LocationBuilder do
  subject { described_class.new(location, radius) }

  let(:point_location) { "SW1A 1AA" }
  let(:radius) { 10 }
  let(:expected_radius) { 1000 }
  let!(:location_polygon) { create(:location_polygon, name: "london") }
  let(:radius_builder) { instance_double(Search::RadiusBuilder, radius: 1000) }

  before do
    allow(Search::RadiusBuilder).to receive(:new).with(location, radius).and_return(radius_builder)
  end

  describe "#initialize" do
    context "when a polygonable location is specified" do
      let(:location) { location_polygon.name }

      it_behaves_like "a search using polygons"
    end

    context "when a mapped location is specified" do
      let(:location) { "Map this location" }

      before do
        allow(MAPPED_LOCATIONS).to receive(:[]).with(location.downcase).and_return(location_polygon.name)
      end

      it_behaves_like "a search using polygons"
    end

    context "when a non-polygonable location is specified" do
      let(:radius_in_metres) { 1_609 * expected_radius }
      let(:location) { point_location }

      it "sets radius attribute, and location filter around the location" do
        expect(subject.polygon).to be_nil
        expect(subject.location_filter).to eq({
          point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
          radius: radius_in_metres,
        })
        expect(subject.radius).to eq(expected_radius)
      end
    end

    context "when a nationwide location is specified" do
      let(:location) { Search::LocationBuilder::NATIONWIDE_LOCATIONS.sample }

      it "does not set location filters" do
        expect(subject.location).to be nil
        expect(subject.polygon).to be nil
        expect(subject.location_filter).to eq({})
      end
    end
  end
end
