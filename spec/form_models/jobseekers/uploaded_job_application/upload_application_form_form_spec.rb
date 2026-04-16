# frozen_string_literal: true

require "rails_helper"

RSpec.describe Jobseekers::UploadedJobApplication::UploadApplicationFormForm, type: :model do
  describe "application_form_scan_safe" do
    let(:job_application) { create(:uploaded_job_application, :with_uploaded_application_form) }
    let(:form) { described_class.new(application_form: job_application.application_form) }

    context "when the blob is malicious" do
      before { job_application.application_form.blob.malware_scan_malicious! }

      it "adds an unsafe_file error" do
        form.valid?
        expect(form.errors.of_kind?(:application_form, :unsafe_file)).to be true
      end
    end

    context "when the blob has a scan error" do
      before { job_application.application_form.blob.malware_scan_scan_error! }

      it "adds an unsafe_file error" do
        form.valid?
        expect(form.errors.of_kind?(:application_form, :unsafe_file)).to be true
      end
    end

    context "when the blob is clean" do
      it "does not add an unsafe_file error" do
        form.valid?
        expect(form.errors.of_kind?(:application_form, :unsafe_file)).to be false
      end
    end
  end
end
