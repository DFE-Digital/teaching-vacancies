require "rails_helper"

RSpec.describe "jobseekers/job_applications/show" do
  let(:jobseeker) { create(:jobseeker) }
  let(:other_job_application) { create(:job_application, jobseeker:) }
  let(:self_disclosure_request) { nil }
  let(:job_application) { create(:job_application) }

  before do
    job_application.self_disclosure_request = self_disclosure_request
    without_partial_double_verification do
      allow(view).to receive_messages(job_application:, vacancy: job_application.vacancy)
    end
    render
  end

  describe "self disclosure request banner" do
    let(:scope) { "jobseekers.job_applications.show.self_disclosure" }
    let(:call_to_action) do
      I18n.t(
        ".cta_html",
        scope:,
        organisation: job_application.vacancy.organisation.name,
        link: "self-disclosure declaration",
      )
    end
    let(:form_path) do
      jobseekers_job_application_self_disclosure_path(job_application, Wicked::FIRST_STEP)
    end

    context "when self_disclosure_request sent" do
      let(:job_application) { create(:job_application, :status_interviewing) }
      let(:self_disclosure_request) { create(:self_disclosure_request, :sent, job_application:) }

      it { expect(rendered).to have_content(call_to_action) }
      it { expect(rendered).to have_link(I18n.t(".form", scope:), href: form_path) }
    end

    context "when self_disclosure_request manual" do
      let(:job_application) { create(:job_application, :status_interviewing) }
      let(:self_disclosure_request) { create(:self_disclosure_request, :manual) }

      it { expect(rendered).to have_no_content(call_to_action) }
      it { expect(rendered).to have_no_link(I18n.t(".form", scope:), href: form_path) }
    end

    context "when job application not status interviewing" do
      it { expect(rendered).to have_no_content(call_to_action) }
      it { expect(rendered).to have_no_link(I18n.t(".form", scope:), href: form_path) }
    end
  end
end
