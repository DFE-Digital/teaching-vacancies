require "rails_helper"

RSpec.describe Publishers::AtsApi::UpdateVacancyService do
  subject(:update_vacancy_service) { described_class.call(vacancy, params) }

  let(:vacancy) do
    create(
      :vacancy,
      :external,
      external_reference: "old-ref",
      publisher_ats_api_client_id: publisher_ats_api_client_id,
      job_title: "English Teacher",
      expires_at: "2025-12-31",
      organisations: [school],
      ect_status: "ect_unsuitable",
    )
  end
  let(:publisher_ats_api_client_id) { create(:publisher_ats_api_client).id }
  let(:school) { create(:school) }
  let(:school_urns) { { school_urns: [school.urn] } }
  let(:job_title) { vacancy.job_title }
  let(:job_advert) { vacancy.job_advert }
  let(:job_roles) { vacancy.job_roles }
  let(:working_patterns) { vacancy.working_patterns }
  let(:params) do
    {
      external_reference: "new-ref",
      job_title: job_title,
      job_advert: job_advert,
      external_advert_url: vacancy.external_advert_url,
      job_roles: job_roles,
      contract_type: vacancy.contract_type,
      phases: vacancy.phases,
      working_patterns: working_patterns,
      expires_at: vacancy.expires_at,
      skills_and_experience: vacancy.skills_and_experience,
      salary: vacancy.salary,
      schools: school_urns,
      publisher_ats_api_client_id: publisher_ats_api_client_id,
    }
  end

  describe "#call" do
    context "when the update is successful" do
      it "updates the attributes that differ from the original vacancy" do
        update_vacancy_service
        vacancy.reload

        expect(vacancy.working_patterns).to eq(%w[full_time])
        expect(vacancy.external_reference).to eq("new-ref")
      end

      it "keeps the existing value for optional attributes not provided" do
        update_vacancy_service
        vacancy.reload

        expect(vacancy.ect_status).to eq("ect_unsuitable")
      end

      context "when providing a new value for optional params" do
        let(:params) { super().merge(ect_suitable: true) }

        it "updates the value" do
          update_vacancy_service
          vacancy.reload

          expect(vacancy.ect_status).to eq("ect_suitable")
        end
      end
    end

    context "when organisations are invalid" do
      let(:school_urns) { { school_urns: [9999] } }

      it "raises Publishers::AtsApi::CreateVacancyService::InvalidOrganisationError" do
        expect { update_vacancy_service }.to raise_error(
          Publishers::AtsApi::OrganisationFetcher::InvalidOrganisationError,
          "No valid organisations found",
        )
      end
    end

    context "when the vacancy fails validation" do
      let(:job_title) { nil }
      let(:job_advert) { nil }
      let(:job_roles) { [] }
      let(:working_patterns) { [] }

      let(:expected_response) do
        {
          success: false,
          errors: [
            "job_title: can't be blank",
            "job_advert: Enter a job advert",
            "job_roles: Select a job role",
            "working_patterns: Select a working pattern",
          ],
        }
      end

      it "returns a validation error response" do
        expect(update_vacancy_service).to eq(expected_response)
      end
    end
  end

  context "when a vacancy with the same external reference exists" do
    let!(:existing_vacancy) do
      create(
        :vacancy,
        :external,
        external_reference: "new-ref",
        publisher_ats_api_client_id: publisher_ats_api_client_id,
      )
    end

    let(:expected_response) do
      {
        status: :conflict,
        json: {
          error: "A vacancy with the provided ATS client ID and external reference already exists.",
          link: Rails.application.routes.url_helpers.vacancy_url(existing_vacancy),
        },
      }
    end

    it "returns a conflict response" do
      expect(update_vacancy_service).to eq(expected_response)
    end
  end

  context "when a vacancy with the same job_title, expired_at, and organisations exists" do
    let!(:existing_vacancy) do
      create(
        :vacancy,
        job_title: "Maths Teacher",
        expires_at: "2026-01-01",
        organisations: [school],
      )
    end

    let(:params) do
      {
        external_reference: "new-ref",
        job_title: "Maths Teacher",
        job_advert: job_advert,
        external_advert_url: vacancy.external_advert_url,
        job_roles: job_roles,
        contract_type: vacancy.contract_type,
        phases: vacancy.phases,
        working_patterns: working_patterns,
        expires_at: "2026-01-01",
        skills_and_experience: vacancy.skills_and_experience,
        salary: vacancy.salary,
        schools: school_urns,
        publisher_ats_api_client_id: publisher_ats_api_client_id,
      }
    end

    let(:expected_response) do
      {
        status: :conflict,
        json: {
          error: "A vacancy with the same job title, expiry date, and organisation already exists.",
          link: Rails.application.routes.url_helpers.vacancy_url(existing_vacancy),
        },
      }
    end

    it "returns a conflict response" do
      expect(update_vacancy_service).to eq(expected_response)
    end
  end
end
