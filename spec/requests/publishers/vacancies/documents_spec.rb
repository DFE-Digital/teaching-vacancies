require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "Documents" do
  include ActionDispatch::TestProcess::FixtureFile

  let(:publisher) { create(:publisher) }
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, :with_supporting_documents, organisations: [organisation]) }

  before do
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "POST #create" do
    before do
      allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
    end

    context "when the form is valid" do
      let(:request) do
        post organisation_job_documents_path(vacancy.id), params: {
          publishers_job_listing_documents_form: { supporting_documents: [fixture_file_upload("blank_job_spec.pdf", "application/pdf")] },
        }
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
      let(:vacancy) { create(:vacancy, include_additional_documents: true, organisations: [organisation]) }

      let(:request) do
        post organisation_job_documents_path(vacancy.id), params: {
          publishers_job_listing_documents_form: { documents: [] },
        }
      end

      it "renders the new page" do
        expect(request).to render_template(:new)
      end
    end
  end

  describe "POST #upload" do
    before do
      allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
    end

    context "when the form is valid" do
      let(:request) do
        post upload_organisation_job_documents_path(vacancy.id), params: {
          documents: fixture_file_upload("blank_job_spec.pdf", "application/pdf"),
        }
      end

      it "triggers an event", :dfe_analytics do
        request
        expect(:supporting_document_created).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
          with_data: { vacancy_id: vacancy.id,
                       document_type: "supporting_document",
                       name: "blank_job_spec.pdf",
                       size: vacancy.supporting_documents.first.byte_size,
                       content_type: "application/pdf" },
        )
      end
    end

    context "MIME type inspection" do
      let(:valid_file_types) { "PDF, DOC or DOCX" }

      before do
        post upload_organisation_job_documents_path(vacancy.id), params: {
          documents: file,
        }
      end

      context "with a valid PDF file" do
        let(:file) { fixture_file_upload("blank_job_spec.pdf") }

        it "is accepted" do
          expect(response.body).not_to include(I18n.t("jobs.file_type_error_message", filename: "blank_job_spec.pdf", valid_file_types: valid_file_types))
        end
      end

      context "with a valid Office 2007+ file" do
        # This makes sure we don't have a regression - Office 2007+ files are notoriously hard to
        # do proper MIME type detection on as they masquerade as ZIP files
        let(:file) { fixture_file_upload("mime_types/valid_word_document.docx") }

        it "is accepted" do
          expect(response.body).not_to include("has an invalid content type")
        end
      end

      context "with a file with a valid extension but invalid 'real' MIME type" do
        let(:file) { fixture_file_upload("mime_types/zip_file_pretending_to_be_a_pdf.pdf") }

        it "is rejected even if the file extension suggests it is valid" do
          expect(response.body).to include("has an invalid content type")
        end
      end

      context "with an invalid file type" do
        let(:file) { fixture_file_upload("mime_types/invalid_plain_text_file.txt") }

        it "is rejected even if the file extension suggests it is valid" do
          expect(response.body).to include("has an invalid content type")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:vacancy) { create(:vacancy, :with_supporting_documents, organisations: [organisation]) }
    let(:document) { vacancy.supporting_documents.first }
    let(:request) { delete organisation_job_document_path(id: document.id, job_id: vacancy.id) }

    it "triggers an event", :dfe_analytics do
      request
      expect(:supporting_document_deleted).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
        with_data: { vacancy_id: vacancy.id,
                     document_type: "supporting_document",
                     name: "blank_job_spec.pdf",
                     size: vacancy.supporting_documents.first.byte_size,
                     content_type: "application/pdf" },
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
        expect(request).to redirect_to(organisation_job_build_path(vacancy.id, :include_additional_documents))
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

  describe "POST #delete_uploaded_file" do
    let(:vacancy) { create(:vacancy, :with_supporting_documents, organisations: [organisation]) }
    let(:document) { vacancy.supporting_documents.first }
    let(:request) { post remove_organisation_job_documents_path(vacancy.id, params: { delete: document.filename }, format: :json) }

    it "triggers an event", :dfe_analytics do
      request
      expect(:supporting_document_deleted).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
        with_data: { vacancy_id: vacancy.id,
                     document_type: "supporting_document",
                     name: "blank_job_spec.pdf",
                     size: vacancy.supporting_documents.first.byte_size,
                     content_type: "application/pdf" },
      )
    end

    it "removes the document" do
      request

      expect(response.parsed_body).to eq("success" => true)
      expect(vacancy.reload.supporting_documents).to be_empty
    end
  end
end
