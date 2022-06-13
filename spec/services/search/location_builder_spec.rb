require "rails_helper"

RSpec.shared_examples "a search using polygons" do
  it "sets the correct attributes" do
    buffered_polygon = LocationPolygon.buffered(expected_radius).find_by(name: location_polygon.name)
    expect(subject.polygon.area).to eq(buffered_polygon.area)
    expect(subject.radius).to eq(expected_radius)
  end
end

RSpec.describe Search::LocationBuilder do
  subject { described_class.new(location, radius, travel_time, transportation_type) }

  let(:point_location) { "SW1A 1AA" }
  let(:radius) { 10 }
  let(:expected_radius) { 1000 }
  let!(:location_polygon) { create(:location_polygon, name: "london") }
  let(:radius_builder) { instance_double(Search::LocationBuilder, radius: 1000) }

  before do
    allow(Search::LocationBuilder).to receive(:new).with(location, radius).and_return(radius_builder)
  end
end
