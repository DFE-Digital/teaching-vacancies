require "rails_helper"

RSpec.describe "Job applications self disclosure" do
  let(:vacancy) { create(:vacancy) }
  let(:organisation) { vacancy.organisations.first }
  let(:job_application) { create(:job_application, :status_submitted, vacancy:) }
  let(:batch) { JobApplicationBatch.create!(vacancy: vacancy) }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
    sign_in(publisher, scope: :publisher)
    batch.batchable_job_applications.create!(job_application: job_application)
  end

  after { sign_out(publisher) }

  describe "GET #show" do
    context "when form incomplete" do
      before do
        get(
          organisation_job_job_application_batch_references_and_self_disclosure_path(
            vacancy.id,
            batch.id,
            :collect_references,
          ),
        )
      end

      it { expect(response).to have_http_status(:ok) }
    end

    context "when form complete" do
      before do
        get(
          organisation_job_job_application_batch_references_and_self_disclosure_path(
            vacancy.id,
            batch.id,
            Wicked::FINISH_STEP,
          ),
        )
      end

      it { expect(response).to have_http_status(:redirect) }
    end
  end

  describe "PATCH #update" do
    context "when invalid" do
      let(:request) do
        patch(
          organisation_job_job_application_batch_references_and_self_disclosure_path(
            vacancy.id,
            batch.id,
            :collect_references,
          ),
          params: {},
        )
      end

      it "renders the template" do
        expect(request).to render_template(:collect_references)
      end
    end

    context "when contact_applicant false" do
      let(:params) do
        {
          publishers_job_application_references_contact_applicant_form: {
            contact_applicants: "false",
          },
        }
      end
      let(:request) do
        patch(
          organisation_job_job_application_batch_references_and_self_disclosure_path(
            vacancy.id,
            batch.id,
            :ask_references_email,
          ),
          params:,
        )
      end

      it { expect(request).to redirect_to(organisation_job_job_applications_path(vacancy.id, anchor: :interviewing)) }

      it { expect { request }.to change(JobApplicationBatch, :count).by(-1) }
      it { expect { request }.to change(SelfDisclosureRequest, :count).by(1) }
      it { expect { request }.to change { job_application.reload.status }.to("interviewing") }
    end
  end
end
