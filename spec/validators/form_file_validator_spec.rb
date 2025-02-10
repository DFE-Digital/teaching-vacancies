require "rails_helper"

class DummyFormFileValidatorForm
  include ActiveModel::Model

  validates :supporting_documents, form_file: {
    file_type: :document,
    content_types_allowed: %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document].freeze,
    file_size_limit: 5.megabytes,
    valid_file_types: %i[PDF DOC DOCX],
  }.freeze

  attr_accessor :supporting_documents
end

RSpec.describe FormFileValidator do
  describe "#validate_each" do
    let(:document_virus_check) { instance_double(Publishers::DocumentVirusCheck, safe?: true) }

    before do
      allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(document_virus_check)
      allow_any_instance_of(described_class).to receive(:validating_files_after_form_submission?).and_return(true)
    end

    context "when the form's file type is a document" do
      let(:form_with_documents) { DummyFormFileValidatorForm.new({ supporting_documents: [uploaded_document] }) }
      let(:uploaded_document) { fixture_file_upload("blank_job_spec.pdf", "application/pdf") }

      context "when the document is valid" do
        before do
          form_with_documents.valid?
        end

        it "does not add any errors to the form object" do
          expect(form_with_documents.errors).to be_blank
        end
      end

      context "when the file's size is too large" do
        before do
          allow(uploaded_document).to receive(:size).and_return(11.megabytes)
          form_with_documents.valid?
        end

        it "adds an error to the form object for the documents field" do
          expect(form_with_documents.errors.full_messages_for(:supporting_documents)).to include("The selected file must be smaller than 5 MB")
        end
      end

      context "when the file is not a valid file type" do
        let(:valid_file_types_for_error_message) { "PDF, DOC or DOCX" }
        let(:error_message) { I18n.t("jobs.file_type_error_message", filename: uploaded_document.original_filename, valid_file_types: valid_file_types_for_error_message) }
        let(:uploaded_document) { fixture_file_upload("blank_image.png", "image/png") }

        before { form_with_documents.valid? }

        it "adds an error to the form object for the documents field" do
          expect(form_with_documents.errors.full_messages_for(:supporting_documents)).to include(error_message)
        end
      end

      context "when the document virus check determines the file as being unsafe" do
        let(:error_message) { I18n.t("jobs.file_virus_error_message", filename: uploaded_document.original_filename) }

        before do
          allow(document_virus_check).to receive(:safe?).and_return(false)
          form_with_documents.valid?
        end

        it "adds an error to the form object for the documents field" do
          expect(form_with_documents.errors.full_messages_for(:supporting_documents)).to include(error_message)
        end
      end
    end
  end
end
