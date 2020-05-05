require 'rails_helper'
require 'geocoding'

RSpec.describe Api::CoordinatesController, type: :controller do
  let(:json) { JSON.parse(response.body, symbolize_names: true) }
  let!(:location_query) { 'ct9' }

  before(:each, :json) do
    request.accept = 'application/json'
  end

  before(:each) do
    request.headers['origin'] = Rails.application.config.allowed_cors_origin
  end

  describe 'GET /api/v1/coordinates/ct9.html' do
    it 'returns status :not_found as only CSV and JSON format is allowed' do
      get :show, params: { api_version: 1, location: location_query }, format: :html

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/coordinates/ct9.json', json: true do
    let(:geocoding) { Geocoding.new(location_query) }
    let(:response_lat) { 51.3819717084213 }
    let(:response_lng) { 1.3872449570364702 }

    it 'with a findable place it returns coordinates, the query, and success' do
      allow(Geocoding).to receive(:new).with(location_query).and_return(geocoding)
      allow(geocoding).to receive(:coordinates).and_return([response_lat, response_lng])

      get :show, params: { api_version: 1, location: location_query }

      expect(json[:lat]).to eq response_lat
      expect(json[:lng]).to eq response_lng
      expect(json[:query]).to eq location_query
      expect(json[:success]).to eq true
    end

    it "returns 'success' as 'false' when there is no data from Geocoder" do
      no_place = 'utopia'
      allow(Geocoding).to receive(:new).with(no_place).and_return(geocoding)
      allow(geocoding).to receive(:coordinates).and_return([0, 0])

      get :show, params: { api_version: 1, location: no_place }

      expect(json[:lat]).to eq 0
      expect(json[:lng]).to eq 0
      expect(json[:query]).to eq no_place
      expect(json[:success]).to eq false
    end
  end
end
