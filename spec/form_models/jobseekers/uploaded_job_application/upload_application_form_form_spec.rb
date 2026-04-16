# frozen_string_literal: true

require "rails_helper"

RSpec.describe Jobseekers::UploadedJobApplication::UploadApplicationFormForm, type: :model do
  describe "application_form_scan_safe" do
    let(:blob) { instance_double(ActiveStorage::Blob, filename: "application_form.pdf") }
    let(:attachment) { double(blob: blob) }
    let(:form) { described_class.new(application_form: attachment) }

    context "when the blob is malicious" do
      before do
        allow(blob).to receive(:malware_scan_malicious?).and_return(true)
        allow(blob).to receive(:malware_scan_scan_error?).and_return(false)
      end

      it "adds an unsafe_file error" do
        form.valid?
        expect(form.errors.of_kind?(:application_form, :unsafe_file)).to be true
      end
    end

    context "when the blob has a scan error" do
      before do
        allow(blob).to receive(:malware_scan_malicious?).and_return(false)
        allow(blob).to receive(:malware_scan_scan_error?).and_return(true)
      end

      it "adds an unsafe_file error" do
        form.valid?
        expect(form.errors.of_kind?(:application_form, :unsafe_file)).to be true
      end
    end

    context "when the blob is clean" do
      before do
        allow(blob).to receive(:malware_scan_malicious?).and_return(false)
        allow(blob).to receive(:malware_scan_scan_error?).and_return(false)
      end

      it "does not add an unsafe_file error" do
        form.valid?
        expect(form.errors.of_kind?(:application_form, :unsafe_file)).to be false
      end
    end
  end
end
