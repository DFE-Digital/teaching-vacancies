require 'rails_helper'

RSpec.describe Api::LocationSuggestionController, type: :controller do
  let(:json) { JSON.parse(response.body, symbolize_names: true) }
  let(:location) { 'lo' }

  before(:each, :json) do
    request.accept = 'application/json'
  end

  describe 'GET /api/v1/location_suggestion/lon?format=html' do
    it 'returns status :not_found as only JSON format is allowed' do
      get :show, params: { api_version: 1, location: location }, format: :html

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/location_suggestion/lon?format=json', json: true do
    context 'location is nil' do
      it 'returns status :bad_request' do
        get :show, params: { api_version: 1 }

        expect(response).to have_http_status(:bad_request)
        expect(json[:error]).to eql('Missing location input')
      end
    end

    context 'location is less than 3 characters long' do
      it 'returns status :bad_request' do
        get :show, params: { api_version: 1, location: location }

        expect(response).to have_http_status(:bad_request)
        expect(json[:error]).to eql('Insufficient location input')
      end
    end

    context 'location is 3 or more characters long' do
      let(:location) { 'pla' }
      let(:suggestions) { ['first playful place, UK', 'second place, UK'] }
      let(:matched_terms) { [['playful', 'place'], ['place']] }

      let(:location_suggestion) { double(LocationSuggestion) }

      before do
        allow(LocationSuggestion).to receive(:new).with(location).and_return(location_suggestion)
        allow(location_suggestion).to receive(:suggest_locations).and_return([suggestions, matched_terms])
      end

      it 'returns status :ok' do
        get :show, params: { api_version: 1, location: location }

        expect(response).to have_http_status(:ok)
        expect(json[:query]).to eql(location)
        expect(json[:suggestions]).to eql(suggestions)
        expect(json[:matched_terms]).to eql(matched_terms)
      end
    end
  end
end
