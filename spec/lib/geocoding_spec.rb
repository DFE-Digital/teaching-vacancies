require "rails_helper"

RSpec.describe Geocoding do
  context "Retrieving the coordinates for a postcode" do
    it "returns the correct value when the input is a valid postcode" do
      geocoding = Geocoding.new("TS14 6RD")
      expect(geocoding.coordinates).to eq(Geocoder::DEFAULT_STUB_COORDINATES)
    end

    it "returns [0,0] when the input is invalid" do
      Geocoder::Lookup::Test.add_stub("TS14", [{}])

      geocoding = Geocoding.new("TS14")
      expect(geocoding.coordinates).to eq([0, 0])
    end
  end
end
