require "rails_helper"

RSpec.describe "Publishers::AtsApi::V1::Vacancies API" do
  let!(:client) { create(:publisher_ats_api_client) }

  describe "GET /ats-api/v1/vacancies" do
    it "only returns vacancies for the authenticated client" do
      other_client = create(:publisher_ats_api_client)
      school = create(:school)
      create_list(:vacancy, 2, :external, publisher_ats_api_client: client, organisations: [school])
      create_list(:vacancy, 3, :external, publisher_ats_api_client: other_client, organisations: [school])

      get "/ats-api/v1/vacancies", headers: { "X-Api-Key" => client.api_key, "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].size).to eq(2)
    end

    it "returns paginated results" do
      create_list(:vacancy, 10, :external, publisher_ats_api_client: client)

      get "/ats-api/v1/vacancies", headers: { "X-Api-Key" => client.api_key, "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].size).to eq(10)
      expect(body["meta"]["totalPages"]).to eq(1)
    end
  end

  describe "POST /ats-api/v1/vacancies" do
    subject(:request) do
      post "/ats-api/v1/vacancies", params: vacancy_params, headers: { "X-Api-Key" => client.api_key, "Accept" => "application/json" }
    end

    let(:source) { build(:vacancy, :external) }
    let!(:school1) { create(:school, name: "Test School", urn: "111111", phase: :primary) }
    let(:schools) { [school1] }

    let(:organisation_ids) do
      {
        school_urns: schools.map { |school| school.urn.to_i },
      }
    end

    let(:vacancy_params) do
      {
        vacancy: {
          external_advert_url: source.external_advert_url,
          expires_at: source.expires_at,
          job_title: source.job_title,
          job_advert: source.job_advert,
          skills_and_experience: source.skills_and_experience,
          salary: source.salary,
          visa_sponsorship_available: source.visa_sponsorship_available,
          external_reference: source.external_reference,
          publisher_ats_api_client_id: client.id,
          is_job_share: source.is_job_share,
          job_roles: source.job_roles,
          working_patterns: source.working_patterns,
          contract_type: source.contract_type,
          phases: source.phases,
          schools: organisation_ids,
        },
      }
    end

    let(:created_vacancy) { Vacancy.last }

    describe "with a single school" do
      it "creates a vacancy and links it to a single school" do
        expect { request }.to change(Vacancy, :count).by(1)
        expect(created_vacancy.organisations).to eq([school1])
      end
    end

    describe "with multiple schools" do
      let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
      let(:schools) { [school1, school2] }

      it "creates a vacancy and links it to multiple schools" do
        request
        expect(created_vacancy.organisations.sort).to eq([school1, school2].sort)
      end
    end

    describe "with a trust central office and no schools" do
      let(:organisation_ids) do
        {
          trust_uid: school_group.uid,
        }
      end
      let(:school_group) { create(:trust, uid: "12345") }

      it "creates a vacancy and links it to the trusts schools" do
        request
        expect(created_vacancy.organisations).to eq([school_group])
      end
    end

    describe "with a trust central office and some schools" do
      let(:organisation_ids) do
        {
          trust_uid: school_group.uid,
          school_urns: schools.map { |school| school.urn.to_i },
        }
      end

      let!(:school2) { create(:school, name: "Test School 2", urn: "222222", phase: :primary) }
      let(:schools) { [school1, school2] }

      let(:school_group) { create(:trust, uid: "12345", schools: schools) }

      it "creates a vacancy and links it to the trusts schools" do
        request
        expect(created_vacancy.organisations.sort).to eq([school1, school2].sort)
      end
    end
  end
end
