require "rails_helper"
require "geocoding"

RSpec.describe "CORS", type: :request do
  describe "/api/v1/jobs.json" do
    scenario "is configured to allow a request from any domain" do
      params = { api_version: 1, format: "json" }
      headers = { 'HTTP_ORIGIN': "https://www.test.com" }
      get api_jobs_path(params), headers: headers

      expect(response.headers["X-Rack-CORS"]).to eq("hit")
      expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
    end
  end

  describe "/api/v1/job/:id.json" do
    let(:vacancy) { create(:vacancy) }

    scenario "is configured to allow a request from any domain" do
      params = { id: vacancy.slug, api_version: 1, format: "json" }
      headers = { 'HTTP_ORIGIN': "https://www.test.com" }
      get api_job_path(params), headers: headers

      expect(response.headers["X-Rack-CORS"]).to eq("hit")
      expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
    end
  end
end
