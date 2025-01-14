require "rails_helper"

RSpec.describe Publishers::AtsApi::V1::CreateVacancyService do
  subject(:service) { described_class.new(params) }

  let(:school) { create(:school) }
  let(:publisher_ats_api_client_id) { create(:publisher_ats_api_client).id }
  let(:external_reference) { "new-ref" }
  let(:school_urns) { { school_urns: [school.urn] } }
  let(:job_title) { "A job title" }
  let(:job_advert) { "A job advert" }
  let(:job_roles) { %w[teacher] }
  let(:working_patterns) { %w[full_time] }
  let(:params) do
    {
      external_reference: external_reference,
      job_title: job_title,
      job_advert: job_advert,
      external_advert_url: "https://example.com",
      job_roles: job_roles,
      contract_type: "fixed_term",
      phases: %w[primary],
      working_patterns: working_patterns,
      expires_at: Time.zone.today + 30,
      skills_and_experience: "Expert in teaching",
      salary: "£30,000 - £40,000",
      schools: school_urns,
      publisher_ats_api_client_id: publisher_ats_api_client_id,
    }
  end

  describe "#call" do
    context "when the vacancy is successfully created" do
      it "returns a success response" do
        expect(service.call).to eq(status: :created, json: { id: Vacancy.last.id })
      end

      it "creates a vacancy with the correct external reference" do
        service.call
        expect(Vacancy.last.external_reference).to eq("new-ref")
      end
    end

    context "when a vacancy with the same external reference exists" do
      let(:external_reference) { "existing-ref" }
      let!(:existing_vacancy) { create(:vacancy, :external, external_reference: "existing-ref") }
      let(:expected_response) do
        {
          status: :conflict,
          json: {
            error: "A vacancy with the provided external reference already exists",
          },
          headers: { "Link" => "<#{Rails.application.routes.url_helpers.vacancy_url(existing_vacancy)}>; rel=\"existing\"" },
        }
      end

      it "returns a conflict response" do
        expect(service.call).to eq(expected_response)
      end
    end

    context "when organisations are invalid" do
      let(:school_urns) { { school_urns: [9999] } }

      it "raises ActiveRecord::RecordNotFound" do
        expect { service.call }
          .to raise_error(
            Publishers::AtsApi::V1::CreateVacancyService::InvalidOrganisationError,
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
          status: :unprocessable_entity,
          json: {
            errors: [
              { error: "job_title: can't be blank" },
              { error: "job_advert: Enter a job advert" },
              { error: "job_roles: Select a job role" },
              { error: "working_patterns: Select a working pattern" },
            ],
          },
        }
      end

      it "returns a validation error response" do
        expect(service.call).to eq(expected_response)
      end
    end
  end
end
