# frozen_string_literal: true

require "rails_helper"

RSpec.describe UploadedJobApplication do
  describe "#uploaded_file" do
    context "when application_form is attached" do
      let(:job_application) { create(:uploaded_job_application, :with_uploaded_application_form) }

      it "returns the blob" do
        expect(job_application.uploaded_file).to eq(job_application.application_form.blob)
      end
    end

    context "when application_form is not attached" do
      let(:job_application) { create(:uploaded_job_application) }

      it "returns nil" do
        expect(job_application.uploaded_file).to be_nil
      end
    end
  end

  describe "#uploaded_file_scan_safe?" do
    context "when application_form is not attached" do
      let(:job_application) { create(:uploaded_job_application) }

      it "returns true" do
        expect(job_application.uploaded_file_scan_safe?).to be true
      end
    end

    context "when application_form blob is clean" do
      let(:job_application) { create(:uploaded_job_application, :with_uploaded_application_form) }

      it "returns true" do
        expect(job_application.uploaded_file_scan_safe?).to be true
      end
    end

    context "when application_form blob is malicious" do
      let(:job_application) { create(:uploaded_job_application, :with_uploaded_application_form) }

      before { job_application.application_form.blob.update!(metadata: { "malware_scan_result" => "malicious" }) }

      it "returns false" do
        expect(job_application.uploaded_file_scan_safe?).to be false
      end
    end

    context "when application_form blob is pending" do
      let(:job_application) { create(:uploaded_job_application, :with_uploaded_application_form) }

      before { job_application.application_form.blob.update_columns(metadata: {}) }

      it "returns false" do
        expect(job_application.uploaded_file_scan_safe?).to be false
      end
    end
  end
end
