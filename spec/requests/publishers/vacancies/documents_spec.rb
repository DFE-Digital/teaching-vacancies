require "rails_helper"

RSpec.describe "Documents" do
  include ActionDispatch::TestProcess::FixtureFile

  let(:publisher) { create(:publisher) }
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }

  before do
    allow_any_instance_of(Publishers::AuthenticationConcerns).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  describe "POST #create" do
    before do
      allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
    end

    it "triggers an event" do
      expect {
        post organisation_job_documents_path(vacancy.id), params: {
          publishers_job_listing_documents_form: { documents: [fixture_file_upload("blank_job_spec.pdf", "application/pdf")] },
        }
      }.to have_triggered_event(:supporting_document_created)
        .with_data(
          vacancy_id: anonymised_form_of(vacancy.id),
          document_type: "supporting_document",
          name: "blank_job_spec.pdf",
          size: 28_527,
          content_type: "application/pdf",
        )
    end

    context "MIME type inspection" do
      before do
        post organisation_job_documents_path(vacancy.id), params: {
          publishers_job_listing_documents_form: { documents: [file] },
        }
      end

      context "with a valid PDF file" do
        let(:file) { fixture_file_upload("blank_job_spec.pdf") }

        it "is accepted" do
          expect(response.body).not_to include(I18n.t("jobs.file_type_error_message", filename: "blank_job_spec.pdf"))
        end
      end

      context "with a valid Office 2007+ file" do
        # This makes sure we don't have a regression - Office 2007+ files are notoriously hard to
        # do proper MIME type detection on as they masquerade as ZIP files
        let(:file) { fixture_file_upload("mime_types/valid_word_document.docx") }

        it "is accepted" do
          expect(response.body).not_to include(I18n.t("jobs.file_type_error_message", filename: "valid_word_document.docx"))
        end
      end

      context "with a file with a valid extension but invalid 'real' MIME type" do
        let(:file) { fixture_file_upload("mime_types/zip_file_pretending_to_be_an_image.png") }

        it "is rejected even if the file extension suggests it is valid" do
          expect(response.body).to include(I18n.t("jobs.file_type_error_message", filename: "zip_file_pretending_to_be_an_image.png"))
        end
      end

      context "with an invalid file type" do
        let(:file) { fixture_file_upload("mime_types/invalid_plain_text_file.txt") }

        it "is rejected even if the file extension suggests it is valid" do
          expect(response.body).to include(I18n.t("jobs.file_type_error_message", filename: "invalid_plain_text_file.txt"))
        end
      end
    end
  end
end
