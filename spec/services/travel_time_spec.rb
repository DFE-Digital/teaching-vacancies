require "rails_helper"

RSpec.describe TravelTime do
  subject(:service) { described_class.new(location, transportation_type, travel_time_in_minutes) }

  let(:location) { "N7 7AJ" }
  let(:transportation_type) { "public_transport" }
  let(:travel_time_in_minutes) { "45" }

  describe "#commute_area" do
    let(:response) { JSON.parse(file_fixture("travel_time_commute_area.json").read) }
    let(:commute_area) { subject.commute_area }
    let(:first_polygon_in_response) { response["results"].first["shapes"].map { |polygon| polygon["shell"] }.first.map(&:values) }
    let(:first_commute_area_polygon) { commute_area.coordinates.first.first }

    before { allow(HTTParty).to receive(:post).and_return(response) }

    it "returns a commute area polygon" do
      expect(commute_area).to be_instance_of(RGeo::Geographic::SphericalMultiPolygonImpl)
      expect(first_commute_area_polygon).to eq(first_polygon_in_response.map(&:reverse))
    end
  end
end
