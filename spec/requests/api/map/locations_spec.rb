require "rails_helper"

RSpec.describe "Api::Map::Locations" do
  let(:location) { "london" }
  let(:radius) { "0" }
  let(:point) { [1.0, 2.0] }
  let(:search_with_polygons) { true }
  let(:json) { JSON.parse(response.body, symbolize_names: true) }
  let(:location_builder_double) do
    instance_double Search::LocationBuilder, search_with_polygons?: search_with_polygons,
                                             polygon_boundaries: [],
                                             point_coordinates: point
  end

  before do
    allow(Search::LocationBuilder).to receive(:new).with(location, radius).and_return(location_builder_double)
    allow(Geocoding).to receive(:new).and_return(instance_double(Geocoding, coordinates: point))
  end

  describe "GET /api/v1/maps/locations/:id.json", json: true do
    subject do
      get api_map_location_path(location, api_version: 1, radius: radius, format: :json)
    end

    it "returns status :not_found if the request format is not JSON" do
      get api_map_location_path(location, api_version: 1, format: :html)

      expect(response.status).to eq(Rack::Utils.status_code(:not_found))
    end

    context "sets headers" do
      before { subject }

      it_behaves_like "X-Robots-Tag"
      it_behaves_like "Content-Type JSON"
    end

    it "returns status code :ok" do
      subject
      expect(response.status).to eq(Rack::Utils.status_code(:ok))
    end

    context "when location is a polygon" do
      before { subject }

      it "returns a polygon" do
        expect(json.first).to include(type: "polygon")
        expect(json.first[:data][:point]).to eq point
        expect(json.first[:data][:coordinates]).to eq []
      end
    end

    context "when location is not a polygon" do
      let(:search_with_polygons) { false }

      before { subject }

      it "returns a marker" do
        expect(json.first).to include(type: "marker")
        expect(json.first[:data][:point]).to eq point
      end
    end
  end
end
