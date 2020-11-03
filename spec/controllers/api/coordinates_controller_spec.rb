require "rails_helper"

RSpec.describe Api::CoordinatesController, type: :controller do
  let(:json) { JSON.parse(response.body, symbolize_names: true) }
  let!(:location_query) { "abingdon" }

  before(:each, :json) do
    request.accept = "application/json"
  end

  describe "GET /api/v1/coordinates/abingdon.html" do
    it "returns status :not_found as only JSON format is allowed" do
      get :show, params: { api_version: 1, location: location_query }, format: :html

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/coordinates/abingdon.json", json: true do
    it "with a findable place it returns coordinates, the query, and success" do
      get :show, params: { api_version: 1, location: location_query }

      expect([json[:lat], json[:lng]]).to eq Geocoder::DEFAULT_STUB_COORDINATES
      expect(json[:query]).to eq location_query
      expect(json[:success]).to eq true
    end

    it "returns 'success' as 'false' when there is no data from Geocoder" do
      Geocoder::Lookup::Test.add_stub("utopia", [{}])

      get :show, params: { api_version: 1, location: "utopia" }

      expect([json[:lat], json[:lng]]).to eq [0, 0]
      expect(json[:query]).to eq "utopia"
      expect(json[:success]).to eq false
    end
  end
end
