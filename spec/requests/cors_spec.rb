require "rails_helper"

RSpec.describe "CORS" do
  describe "/api/v1/location_suggestion/:location.json" do
    let(:location_query) { "buckingham palace" }
    let(:params) { { api_version: 1, location: location_query, format: "json" } }

    before do
      allow_any_instance_of(LocationSuggestion).to receive(:suggest_locations).and_return([[], []])
      get api_location_suggestion_path(params), headers:
    end

    context "when domain is defined in configuration" do
      let(:headers) { { HTTP_ORIGIN: Rails.application.config.allowed_cors_origin.call } }

      it "allows the request" do
        expect(response.headers["X-Rack-CORS"]).to eq("hit")
        expect(response.headers["Access-Control-Allow-Origin"]).to eq(Rails.application.config.allowed_cors_origin.call)
      end
    end

    context "when domain is not defined in configuration" do
      let(:headers) { { HTTP_ORIGIN: "https://www.test.com" } }

      it "does not allow the request" do
        expect(response.headers["X-Rack-CORS"]).to include("miss")
        expect(response.headers["Access-Control-Allow-Origin"]).to be_blank
      end
    end
  end

  describe "/api/v1/jobs.json" do
    let(:params) { { api_version: 1, format: "json" } }
    let(:headers) { { HTTP_ORIGIN: "https://www.test.com" } }

    before do
      get api_jobs_path(params), headers:
    end

    it "is configured to allow a request from any domain" do
      expect(response.headers["X-Rack-CORS"]).to eq("hit")
      expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
    end
  end

  describe "/api/v1/job/:id.json" do
    let(:vacancy) { create(:vacancy) }
    let(:params) { { id: vacancy.slug, api_version: 1, format: "json" } }
    let(:headers) { { HTTP_ORIGIN: "https://www.test.com" } }

    before do
      get api_job_path(params), headers:
    end

    it "is configured to allow a request from any domain" do
      expect(response.headers["X-Rack-CORS"]).to eq("hit")
      expect(response.headers["Access-Control-Allow-Origin"]).to eq("*")
    end
  end
end
