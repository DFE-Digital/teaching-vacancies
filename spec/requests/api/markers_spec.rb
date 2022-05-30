require "rails_helper"

RSpec.describe "Api::Markers" do
  let(:json) { JSON.parse(response.body, symbolize_names: true) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:marker_type) { "vacancy" }

  describe "GET /api/v1/markers/:id.json?parent_id=:parent_id", json: true do
    subject do
      get api_marker_path(vacancy.id, api_version: 1), params: { parent_id: organisation.id, marker_type: marker_type, format: :json }
    end

    it "returns status :not_found if the request format is not JSON" do
      get api_marker_path(vacancy.id, api_version: 1), params: { parent_id: organisation.id, marker_type: marker_type, format: :html }

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

    context "when marker_type is vacancy" do
      it "returns the JSON marker" do
        subject
        expect(json).to include(heading_text: vacancy.job_title)
        expect(json).to include(heading_url: job_path(vacancy))
        expect(json).to include(name: organisation.name)
        expect(json).to include(anonymised_id: StringAnonymiser.new(vacancy.id).to_s)
        expect(json).to include(address: full_address(organisation))
        expect(json).to include(description: nil)
        expect(json[:details].size).to be 4
      end
    end

    context "when marker_type is organisation" do
      let(:marker_type) { "organisation" }

      it "returns the JSON marker" do
        subject
        expect(json).to include(heading_text: organisation.name)
        expect(json).to include(heading_url: organisation.url)
        expect(json).to include(anonymised_id: StringAnonymiser.new(vacancy.id).to_s)
        expect(json).to include(address: full_address(organisation))
        expect(json).to include(description: organisation_type(organisation))
        expect(json).to include(details: nil)
      end
    end

    context "when missing params" do
      it "returns status :bad_request" do
        get api_marker_path(vacancy.id, api_version: 1), params: { format: :json }

        expect(response).to have_http_status(:bad_request)
        expect(json[:error]).to eq("Missing params")
      end
    end
  end
end
