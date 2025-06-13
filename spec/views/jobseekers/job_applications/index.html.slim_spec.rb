require "rails_helper"

RSpec.describe "jobseekers/job_applications/index" do
  let(:jobseeker) { create(:jobseeker) }
  let(:other_job_application) { create(:job_application, jobseeker:) }
  let(:self_disclosure_request) { nil }

  before do
    jobseeker.job_applications << self_disclosure_request.job_application if self_disclosure_request
    allow(view).to receive(:current_jobseeker).and_return(jobseeker)
    render
  end

  describe "self disclosure request tag" do
    context "when self_disclosure_request sent" do
      let(:job_application) { create(:job_application, :status_interviewing) }
      let(:self_disclosure_request) { create(:self_disclosure_request, :sent, job_application:) }

      it { expect(rendered).to have_content("info required") }
    end

    context "when self_disclosure_request manual" do
      let(:self_disclosure_request) { create(:self_disclosure_request, :manual) }

      it { expect(rendered).to have_no_content("info required") }
    end

    context "when self_disclosure_request missing" do
      it { expect(rendered).to have_no_content("info required") }
    end
  end
end
