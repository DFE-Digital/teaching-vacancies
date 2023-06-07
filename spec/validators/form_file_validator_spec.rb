require "rails_helper"

RSpec.describe FormFileValidator do
  describe "#validate_each" do
    before { allow_any_instance_of(described_class).to receive(:validating_files_after_form_submission?).and_return(true) }

    context "when the form's file type is a document" do
      let(:subject) { described_class.new(attributes: [attribute]) }
      let(:form_with_documents) { Publishers::JobListing::DocumentsForm.new(supporting_documents: [uploaded_document]) }
      let(:attribute) { :supporting_documents }
      let(:uploaded_document) { fixture_file_upload("blank_job_spec.pdf", "application/pdf") }

      before { allow_any_instance_of(Publishers::DocumentVirusCheck).to receive(:safe?).and_return(true) }

      it "runs the correct validations" do
        expect(subject).to receive(:validate_each_document)

        subject.validate_each(form_with_documents, attribute, uploaded_document)
      end

      context "when the document is valid" do
        it "does not add any errors to the form object" do
          expect(form_with_documents.errors).to be_blank

          subject.validate_each(form_with_documents, attribute, uploaded_document)
        end
      end

      context "when the file's size is too large" do
        before do
          allow(form_with_documents).to receive(:file_size_limit).and_return(5.megabytes)
          allow(uploaded_document).to receive(:size).and_return(10.megabytes)
          subject.validate_each(form_with_documents, attribute, uploaded_document)
        end

        it "adds an error to the form object for the documents field" do
          expect(form_with_documents.errors.full_messages_for(attribute)).to include("The selected file must be smaller than 5 MB")
        end
      end

      context "when the file is not a valid file type" do
        let(:valid_file_types_for_error_message) { form_with_documents.valid_file_types.to_sentence(two_words_connector: " or ", last_word_connector: " or ") }
        let(:error_message) { I18n.t("jobs.file_type_error_message", filename: uploaded_document.original_filename, valid_file_types: valid_file_types_for_error_message) }
        let(:invalid_document) { fixture_file_upload("blank_image.png", "image/png") }

        before { subject.validate_each(form_with_documents, attribute, invalid_document) }

        it "adds an error to the form object for the documents field" do
          expect(form_with_documents.errors.full_messages_for(attribute)).to include(error_message)
        end
      end

      context "when the document virus check determines the file as being unsafe" do
        let(:error_message) { I18n.t("jobs.file_virus_error_message", filename: uploaded_document.original_filename) }

        before do
          allow_any_instance_of(Publishers::DocumentVirusCheck).to receive(:safe?).and_return(false)
          subject.validate_each(form_with_documents, attribute, uploaded_document)
        end

        it "adds an error to the form object for the documents field" do
          expect(form_with_documents.errors.full_messages_for(attribute)).to include(error_message)
        end
      end
    end

    context "when the form's file type is an image" do
      let(:subject) { described_class.new(attributes: [attribute]) }
      let(:form_with_image) { Publishers::Organisation::LogoForm.new(logo: uploaded_image) }
      let(:attribute) { :logo }
      let(:uploaded_image) { fixture_file_upload("blank_image.png", "image/png") }

      before { allow_any_instance_of(Publishers::DocumentVirusCheck).to receive(:safe?).and_return(true) }

      it "runs the correct validations" do
        expect(subject).to receive(:validate_each_image)

        subject.validate_each(form_with_image, attribute, uploaded_image)
      end

      context "when the image is valid" do
        before { subject.validate_each(form_with_image, attribute, uploaded_image) }

        it "does not add any errors to the form object" do
          expect(form_with_image.errors).to be_blank
        end
      end

      context "when the file's size is too large" do
        before do
          allow(form_with_image).to receive(:file_size_limit).and_return(5.megabytes)
          allow(uploaded_image).to receive(:size).and_return(10.megabytes)
          subject.validate_each(form_with_image, attribute, uploaded_image)
        end

        it "adds an error to the form object for the logo field" do
          expect(form_with_image.errors.full_messages_for(:logo)).to include("The selected file must be smaller than 5 MB")
        end
      end

      context "when the file is not a valid file type" do
        let(:valid_file_types_for_error_message) { form_with_image.valid_file_types.to_sentence(two_words_connector: " or ", last_word_connector: " or ") }
        let(:error_message) { I18n.t("jobs.file_type_error_message", filename: uploaded_image.original_filename, valid_file_types: valid_file_types_for_error_message) }
        let(:invalid_logo) { fixture_file_upload("blank_job_spec.pdf", "application/pdf") }

        before { subject.validate_each(form_with_image, attribute, invalid_logo) }

        it "adds an error to the form object for the logo field" do
          expect(form_with_image.errors.full_messages_for(:logo)).to include(error_message)
        end
      end

      context "when the document virus check determines the image as being unsafe" do
        let(:error_message) { I18n.t("jobs.file_virus_error_message", filename: uploaded_image.original_filename) }

        before do
          allow_any_instance_of(Publishers::DocumentVirusCheck).to receive(:safe?).and_return(false)
          subject.validate_each(form_with_image, attribute, uploaded_image)
        end

        it "adds an error to the form object for the documents field" do
          expect(form_with_image.errors.full_messages_for(:logo)).to include(error_message)
        end
      end
    end
  end
end
