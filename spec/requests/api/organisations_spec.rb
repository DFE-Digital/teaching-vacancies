require "rails_helper"

RSpec.describe "Api::Organisations" do
  let(:json) { JSON.parse(response.body, symbolize_names: true) }
  let(:school) { create(:school) }

  describe "GET /api/v1/organisations/:friendly-id.json" do
    it "returns the API's openapi version" do
      get api_organisation_path(api_version: 1, id: school.friendly_id), params: { format: :json }

      expect(json[:openapi]).to eq("3.0.0")
    end
  end
end
