require "rails_helper"

RSpec.describe "Api::Markers" do
  let(:json) { JSON.parse(response.body, symbolize_names: true) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }

  describe "GET /api/v1/markers/:id.json?parent_id=:parent_id", json: true do
    subject do
      get api_marker_path(vacancy.id, api_version: 1), params: { parent_id: organisation.id, format: :json }
    end

    it "returns status :not_found if the request format is not JSON" do
      get api_marker_path(vacancy.id, api_version: 1), params: { parent_id: organisation.id, format: :html }

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

    it "returns the JSON marker" do
      subject
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to include("heading_text" => vacancy.job_title)
      expect(parsed_response).to include("heading_url" => job_path(vacancy))
      expect(parsed_response).to include("address" => full_address(organisation))
    end
  end
end
