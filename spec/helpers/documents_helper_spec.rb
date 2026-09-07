require "rails_helper"

RSpec.describe DocumentsHelper do
  describe "#document_filename" do
    subject(:document_filename) { helper.document_filename(vacancy, vacancy.application_form) }

    context "when the document has passed malware scanning" do
      let(:vacancy) { create(:vacancy, :with_uploaded_application_form) }

      it "returns a link to the document" do
        expect(document_filename).to include(job_document_path(vacancy, vacancy.application_form.id))
        expect(document_filename).to include("blank_job_spec.pdf")
      end
    end

    context "when the document has not passed malware scanning" do
      let(:vacancy) { create(:vacancy, :with_uploaded_application_form) }

      before { vacancy.application_form.blob.malware_scan_pending! }

      it "returns the filename without a link" do
        expect(document_filename).not_to include("<a")
        expect(document_filename).to include("blank_job_spec.pdf")
      end
    end

    context "when no document is attached" do
      let(:vacancy) { create(:vacancy, enable_job_applications: false, receive_applications: "uploaded_form") }

      it "returns an empty string" do
        expect(document_filename).to eq("")
      end
    end
  end
end
