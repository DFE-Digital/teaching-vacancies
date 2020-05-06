require 'rails_helper'
require 'geocoding'

RSpec.describe 'CORS', type: :request do
  describe '/api/v1/coordinates/:location.json' do
    let(:location_query) { 'abingdon' }

    scenario 'allows a request from a domain defined by configuration' do
      params = { api_version: 1, location: location_query, format: 'json' }
      headers = { 'HTTP_ORIGIN': Rails.application.config.allowed_cors_origin }
      get api_path(params), headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.headers['Access-Control-Allow-Origin']).to eq(Rails.application.config.allowed_cors_origin)
    end

    scenario 'does not allow a request from a different domain' do
      params = { api_version: 1, location: location_query, format: 'json' }
      headers = { 'HTTP_ORIGIN': 'https://www.test.com' }
      get api_path(params), headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe '/api/v1/jobs.json' do
    scenario 'is configured to allow a request from any domain' do
      params = { api_version: 1, format: 'json' }
      headers = { 'HTTP_ORIGIN': 'https://www.test.com' }
      get api_jobs_path(params), headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
    end
  end

  describe '/api/v1/job/:id.json' do
    let(:vacancy) { create(:vacancy) }

    scenario 'is configured to allow a request from any domain' do
      params = { id: vacancy.slug, api_version: 1, format: 'json' }
      headers = { 'HTTP_ORIGIN': 'https://www.test.com' }
      get api_job_path(params), headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
    end
  end
end
