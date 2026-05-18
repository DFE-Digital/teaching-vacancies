# frozen_string_literal: true

require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/pre_interview_checks" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_interviewing, vacancy: vacancy) }
  let(:referee) { create(:referee, job_application: job_application) }
  let(:reference_request) { create(:reference_request, referee: referee, status: :received_off_service) }
  let(:filename) { "reference.pdf" }

  before do
    reference_request.reference_form.attach(
      io: Rails.root.join("spec/fixtures/files/blank_job_spec.pdf").open,
      filename: filename,
      content_type: "application/pdf",
    )

    assign :vacancy, vacancy
    assign :job_application, job_application
    assign :reference_requests, [reference_request]
  end

  context "when the reference document scan is pending" do
    before do
      reference_request.reference_form.blob.malware_scan_pending!
      render
    end

    it "shows the filename without a download link" do
      expect(rendered).to have_content(filename)
      expect(rendered).to have_no_link(filename, href: rails_blob_path(reference_request.reference_form))
    end
  end

  context "when the reference document scan is clean" do
    before do
      reference_request.reference_form.blob.malware_scan_clean!
      render
    end

    it "shows a download link" do
      expect(rendered).to have_link(filename, href: rails_blob_path(reference_request.reference_form))
    end
  end
end
