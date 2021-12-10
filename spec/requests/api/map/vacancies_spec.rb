require "rails_helper"

RSpec.describe "Api::Map::Vacancies" do
  let(:json) { JSON.parse(response.body, symbolize_names: true) }
  let(:organisation) { create(:school) }

  describe "GET /api/v1/maps/vacancies/:id.json", json: true do
    let(:vacancy) { create(:vacancy, organisations: [organisation]) }

    subject do
      get api_map_vacancy_path(vacancy.id, api_version: 1, format: :json)
    end

    it "returns status :not_found if the request format is not JSON" do
      get api_map_vacancy_path(vacancy.id, api_version: 1, format: :html)

      expect(response.status).to eq(Rack::Utils.status_code(:not_found))
    end

    context "sets headers" do
      before { subject }

      it_behaves_like "X-Robots-Tag"
      it_behaves_like "Content-Type JSON"
    end

    it "returns status code :ok" do
      subject
      expect(response).to be_ok
    end

    context "when vacancy is at one school" do
      before { subject }

      it "returns markers of the organisations" do
        expect(json).to include(expected_marker(organisation))
      end
    end

    context "when vacancy is at multiple schools" do
      let(:organisation_two) { create(:school) }
      let(:organisation_three) { create(:school) }

      let(:vacancy) { create(:vacancy, organisations: [organisation, organisation_two, organisation_three]) }

      before { subject }

      it "returns markers of the organisations" do
        expect(json).to include(
          expected_marker(organisation),
          expected_marker(organisation_two),
          expected_marker(organisation_three),
        )
      end
    end
  end
end

def expected_marker(organisation)
  {
    type: "marker",
    data: {
      point: [organisation.geopoint.lat, organisation.geopoint.lon],
      meta: {
        name: organisation.name,
        name_link: organisation.url,
        address: full_address(organisation),
        organisation_type: organisation_type(organisation),
      },
    },
  }
end
