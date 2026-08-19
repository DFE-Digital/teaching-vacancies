# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publishers::Vacancies::ReferencesAndSelfDisclosure" do
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let(:batch) do
    batch = JobApplicationBatch.create!(vacancy: vacancy)
    batch.batchable_job_applications.create!(job_application: job_application)
    batch
  end

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "PATCH #update on collect_self_disclosure step" do
    subject(:request) do
      patch(
        organisation_job_job_application_batch_references_and_self_disclosure_path(
          vacancy.id, batch.id, :collect_self_disclosure
        ),
        params: params,
      )
    end

    let(:params) do
      {
        publishers_job_application_collect_self_disclosure_form: {
          collect_self_disclosure: false,
          collect_references: false,
          contact_applicants: false,
        },
      }
    end

    context "when job application has a religious referee and no existing religious reference request" do
      let(:job_application) { create(:job_application, :status_submitted, :with_religious_referee, vacancy: vacancy) }

      it "creates a religious reference request" do
        expect { request }.to change(ReligiousReferenceRequest, :count).by(1)
      end

      it "updates the job application status to interviewing" do
        expect { request }.to change { job_application.reload.status }.to("interviewing")
      end
    end
  end
end
