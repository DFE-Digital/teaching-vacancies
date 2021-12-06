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
      expect(response.status).to eq(Rack::Utils.status_code(:ok))
    end

    context "when vacancy is at one school" do
      before { subject }

      it "returns markers of the organisations" do
        check_marker(json.first, organisation)
      end
    end

    context "when vacancy is at multiple schools" do
      let(:organisation_two) { create(:school) }
      let(:organisation_three) { create(:school) }

      let(:vacancy) { create(:vacancy, organisations: [organisation, organisation_two, organisation_three]) }

      before { subject }

      it "returns markers of the organisations" do
        check_marker(json.first, organisation)
        check_marker(json.second, organisation_two)
        check_marker(json.third, organisation_three)
      end
    end
  end
end

def check_marker(marker, organisation)
  expect(marker).to include(type: "marker")
  expect(marker[:data][:point]).to eq [organisation.geopoint.lat, organisation.geopoint.lon]
  expect(marker[:data][:meta][:name]).to eq organisation.name
  expect(marker[:data][:meta][:name_link]).to eq organisation.url
  expect(marker[:data][:meta][:address]).to eq full_address(organisation)
  expect(marker[:data][:meta][:organisation_type]).to eq organisation_type(organisation)
end
