# frozen_string_literal: true

require "rails_helper"

RSpec.describe NativeJobApplication do
  describe "#uploaded_file" do
    context "when baptism_certificate is attached" do
      let(:job_application) { create(:job_application, :with_baptism_certificate) }

      it "returns the blob" do
        expect(job_application.uploaded_file).to eq(job_application.baptism_certificate.blob)
      end
    end

    context "when baptism_certificate is not attached" do
      let(:job_application) { create(:job_application) }

      it "returns nil" do
        expect(job_application.uploaded_file).to be_nil
      end
    end
  end

  describe "#uploaded_file_scan_safe?" do
    context "when baptism_certificate is not attached" do
      let(:job_application) { create(:job_application) }

      it "returns true" do
        expect(job_application.uploaded_file_scan_safe?).to be true
      end
    end

    context "when baptism_certificate blob is clean" do
      let(:job_application) { create(:job_application, :with_baptism_certificate) }

      it "returns true" do
        expect(job_application.uploaded_file_scan_safe?).to be true
      end
    end

    context "when baptism_certificate blob is malicious" do
      let(:job_application) { create(:job_application, :with_baptism_certificate) }

      before { job_application.baptism_certificate.blob.update!(metadata: { "malware_scan_result" => "malicious" }) }

      it "returns false" do
        expect(job_application.uploaded_file_scan_safe?).to be false
      end
    end

    context "when baptism_certificate blob is pending" do
      let(:job_application) { create(:job_application, :with_baptism_certificate) }

      before { job_application.baptism_certificate.blob.update_columns(metadata: {}) }

      it "returns false" do
        expect(job_application.uploaded_file_scan_safe?).to be false
      end
    end
  end
end
