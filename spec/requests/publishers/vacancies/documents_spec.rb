require "rails_helper"

RSpec.describe "Documents" do
  include ActionDispatch::TestProcess::FixtureFile

  let(:publisher) { create(:publisher) }
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, :with_supporting_documents, organisations: [organisation]) }

  before do
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  describe "POST #create" do
    before do
      allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
    end

    context "when the form is valid" do
      let(:request) do
        post organisation_job_documents_path(vacancy.id), params: {
          publishers_job_listing_documents_form: { documents: [fixture_file_upload("blank_job_spec.pdf", "application/pdf")] },
        }
      end

      it "triggers an event" do
        expect { request }.to have_triggered_event(:supporting_document_created)
                       .with_data(
                         vacancy_id: anonymised_form_of(vacancy.id),
                         document_type: "supporting_document",
                         name: "blank_job_spec.pdf",
                         size: 28_527,
                         content_type: "application/pdf",
                       )
      end

      it "renders the index page" do
        expect(request).to render_template(:index)
      end

      it "adds documents to the completed steps" do
        request

        expect(vacancy.reload.completed_steps).to include("documents")
      end
    end

    context "when the form is invalid" do
      let(:request) do
        post organisation_job_documents_path(vacancy.id), params: {
          publishers_job_listing_documents_form: { documents: [fixture_file_upload("mime_types/invalid_plain_text_file.txt")] },
        }
      end

      it "does not trigger an event" do
        expect { request }.to_not have_triggered_event(:supporting_document_created)
      end

      it "renders the new page" do
        expect(request).to render_template(:new)
      end
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
        let(:file) { fixture_file_upload("mime_types/zip_file_pretending_to_be_a_pdf.pdf") }

        it "is rejected even if the file extension suggests it is valid" do
          expect(response.body).to include(I18n.t("jobs.file_type_error_message", filename: "zip_file_pretending_to_be_a_pdf.pdf"))
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

  describe "DELETE #destroy" do
    let(:vacancy) { create(:vacancy, :with_supporting_documents, organisations: [organisation]) }
    let(:document) { vacancy.supporting_documents.first }
    let(:request) { delete organisation_job_document_path(id: document.id, job_id: vacancy.id) }

    it "triggers an event" do
      expect { request }.to have_triggered_event(:supporting_document_deleted)
                        .with_data(
                          vacancy_id: anonymised_form_of(vacancy.id),
                          document_type: "supporting_document",
                          name: "blank_job_spec.pdf",
                          size: 28_527,
                          content_type: "application/pdf",
                        )
    end

    it "removes the document" do
      request
      follow_redirect!

      expect(response.body).to include(I18n.t("jobs.file_delete_success_message", filename: document.filename))
      expect(vacancy.reload.supporting_documents).to be_empty
    end

    context "when there are no longer any documents attached to the vacancy" do
      it "redirects to the new documents form" do
        expect(request).to redirect_to(new_organisation_job_document_path(vacancy.id))
      end
    end

    context "when other documents are attached to the vacancy" do
      let(:file) { fixture_file_upload("mime_types/valid_word_document.docx") }

      before { vacancy.supporting_documents.attach(file) }

      it "redirects to the documents index page" do
        expect(request).to redirect_to(organisation_job_documents_path(vacancy.id))
      end
    end
  end

  describe "#confirm" do
    let(:request) do
      post confirm_organisation_job_documents_path(vacancy.id), params: {
        publishers_job_listing_documents_confirmation_form: { upload_additional_document: upload_additional_document },
      }
    end

    context "when the form is valid" do
      let(:upload_additional_document) { "false" }

      context "when upload_additional_document is false" do
        it "redirects to the new documents form" do
          expect(request).to redirect_to(organisation_job_path(vacancy.id))
        end
      end

      context "when upload_additional_document is true" do
        let(:upload_additional_document) { "true" }

        it "redirects to the next step" do
          expect(request).to redirect_to(new_organisation_job_document_path(vacancy.id))
        end
      end
    end

    context "when the form is invalid" do
      let(:upload_additional_document) { nil }

      it "renders the documents index page" do
        expect(request).to render_template(:index)
      end
    end
  end
end
