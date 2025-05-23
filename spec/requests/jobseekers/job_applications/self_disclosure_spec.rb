require "rails_helper"

RSpec.describe "Job applications self disclosure" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisations) { [create(:school)] }
  let(:vacancy) { create(:vacancy, organisations:) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy:, jobseeker:) }
  let(:self_disclosure_request) { create(:self_disclosure_request, status:, job_application:) }
  let(:self_disclosure) { create(:self_disclosure, self_disclosure_request:) }

  before do
    sign_in(jobseeker, scope: :jobseeker)
  end

  after { sign_out(jobseeker) }

  describe "GET #show" do
    before do
      self_disclosure
      get jobseekers_job_application_self_disclosure_path(job_application, :personal_details)
    end

    context "when the self disclosure has not been enabled" do
      let(:self_disclosure) { nil }

      it { expect(response).to redirect_to(jobseekers_job_application_path(job_application)) }
    end

    context "when the self disclosure is managed outside TV" do
      let(:status) { "manual" }

      it { expect(response).to redirect_to(jobseekers_job_application_path(job_application)) }
    end

    context "when the self disclosure is pending" do
      let(:status) { "sent" }

      it { expect(response).to have_http_status(:ok) }
    end

    context "when the self disclosure has been completed" do
      let(:status) { "received" }

      it { expect(response).to redirect_to(jobseekers_job_application_path(job_application)) }
    end
  end
end
