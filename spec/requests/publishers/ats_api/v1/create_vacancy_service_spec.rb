require "rails_helper"

RSpec.describe Publishers::AtsApi::V1::CreateVacancyService do
  subject(:service) { described_class.new(params) }

  let(:params) do
    {
      external_reference: "existing-ref",
      schools: { school_urns: [school.urn] },
    }
  end
  let(:school) { create(:school) }
  let(:school_group) { create(:school_group, schools: [school]) }

  describe "#call" do
    context "when a vacancy with the same external reference exists" do
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
      let(:params) do
        {
          external_reference: "new-ref",
          schools: { school_urns: [9999] },
        }
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect { service.call }.to raise_error(ActiveRecord::RecordNotFound, "No valid organisations found")
      end
    end

    context "when the vacancy is successfully created" do
      let(:params) do
        {
          external_reference: "new-ref",
          job_title: "Teacher",
          job_advert: "A job advert",
          external_advert_url: "https://example.com",
          job_roles: %w[teacher],
          contract_type: "fixed_term",
          phases: %w[primary],
          working_patterns: %w[full_time],
          expires_at: Date.today + 30,
          skills_and_experience: "Expert in teaching",
          salary: "£30,000 - £40,000",
          schools: { school_urns: [school.urn] },
        }
      end

      it "returns a success response" do
        expect(service.call).to eq(status: :created, json: { id: Vacancy.last.id })
      end

      it "creates a vacancy with the correct external reference" do
        service.call
        expect(Vacancy.last.external_reference).to eq("new-ref")
      end
    end

    context "when the vacancy fails validation" do
      let(:params) do
        {
          external_reference: "new-ref",
          job_title: nil,
          expires_at: Date.today + 30,
          external_advert_url: "https://example.com",
          skills_and_experience: "Expert in teaching",
          contract_type: "fixed_term",
          salary: "£30,000 - £40,000",
          phases: %w[primary],
          schools: { school_urns: [school.urn] },
        }
      end

      let(:expected_response) do
        {
          status: :unprocessable_entity,
          json: {
            errors: [
              { error: "job_title: can't be blank" },
              { error: "job_advert: Enter a job advert" },
              { error: "job_roles: Select a job role" },
              { error: "working_patterns: Select a working pattern" },
            ]
          }
        }
      end

      it "returns a validation error response" do
        expect(service.call).to eq(expected_response)
      end
    end
  end
end
