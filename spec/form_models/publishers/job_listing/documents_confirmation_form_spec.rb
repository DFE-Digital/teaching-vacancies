# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publishers::JobListing::DocumentsConfirmationForm, type: :model do
  let(:vacancy) { create(:vacancy, :with_supporting_documents) }
  let(:form) { described_class.new({ upload_additional_document: "false" }, vacancy) }

  describe "additional_documents_scan_safe" do
    context "when a supporting document blob is malicious" do
      before { vacancy.supporting_documents.first.blob.malware_scan_malicious! }

      it "adds an error" do
        form.valid?
        expect(form.errors[:base]).to include(
          I18n.t("jobs.file_unsafe_error_message", filename: vacancy.supporting_documents.first.filename),
        )
      end
    end

    context "when a supporting document blob has a scan error" do
      before { vacancy.supporting_documents.first.blob.malware_scan_scan_error! }

      it "adds an error" do
        form.valid?
        expect(form.errors[:base]).to include(
          I18n.t("jobs.file_unsafe_error_message", filename: vacancy.supporting_documents.first.filename),
        )
      end
    end

    context "when all supporting document blobs are clean" do
      before { vacancy.supporting_documents.each { |doc| doc.blob.malware_scan_clean! } }

      it "does not add any errors" do
        form.valid?
        expect(form.errors[:base]).to be_empty
      end
    end
  end
end
