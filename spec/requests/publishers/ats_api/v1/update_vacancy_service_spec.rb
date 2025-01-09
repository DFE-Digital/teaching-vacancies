require "rails_helper"

RSpec.describe Publishers::AtsApi::V1::UpdateVacancyService do
  subject(:service) { described_class.new(vacancy, params) }

  let(:vacancy) { create(:vacancy, :external, organisations: [school]) }
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
    }
  end

  describe "#call" do
    context "when the update is successful" do
      it "updates only the attributes that differ from the original vacancy" do
        service.call
        vacancy.reload

        expect(vacancy.working_patterns).to eq(%w[full_time])
        expect(vacancy.external_reference).to eq("new-ref")
      end
    end

    context "when organisations are invalid" do
      let(:school_urns) { { school_urns: [9999] } }

      it "raises ActiveRecord::RecordNotFound" do
        expect { service.call }.to raise_error(ActiveRecord::RecordNotFound, "No valid organisations found")
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
