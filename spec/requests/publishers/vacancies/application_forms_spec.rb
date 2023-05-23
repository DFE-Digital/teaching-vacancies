require "rails_helper"

RSpec.describe "Documents" do
  include ActionDispatch::TestProcess::FixtureFile

  let(:publisher) { create(:publisher) }
  let(:organisation) { build(:school) }

  before do
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  describe "POST #create" do
    let(:vacancy) { create(:vacancy, enable_job_applications: false, receive_applications: "email", organisations: [organisation]) }
    let(:valid_file) { fixture_file_upload("blank_job_spec.pdf", "application/pdf") }
    let(:application_email) { "test@example.com" }
    let(:request) do
      post organisation_job_application_forms_path(vacancy.id), params: {
        publishers_job_listing_application_form_form: {
          application_form: valid_file,
          application_email: application_email,
        },
      }
    end

    before do
      allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
    end

    context "when the form is valid" do
      it "triggers an event" do
        expect { request }.to have_triggered_event(:supporting_document_created)
          .with_data(
            vacancy_id: vacancy.id,
            document_type: "application_form",
            name: "blank_job_spec.pdf",
            size: 28_527,
            content_type: "application/pdf",
          )
      end

      it "attaches the application form to the vacancy" do
        request

        expect(vacancy.application_form.filename.to_s).to eq(valid_file.original_filename)
      end

      it "updates the vacancy" do
        request

        expect(vacancy.reload.application_email).to eq(application_email)
      end

      it "adds application_form to the completed steps" do
        request

        expect(vacancy.reload.completed_steps).to include("application_form")
      end

      context "when the vacancy is listed" do
        before do
          allow(vacancy).to receive(:listed?).and_return(true)
          allow_any_instance_of(Publishers::Vacancies::BaseController).to receive(:update_google_index)
        end

        it "updates the google index" do
          request

          expect(controller).to have_received(:update_google_index).with(vacancy)
        end
      end

      context "when all steps are valid" do
        before { allow_any_instance_of(Publishers::Vacancies::BaseController).to receive(:all_steps_valid?).and_return(true) }

        it "redirects to the show page" do
          expect(request).to redirect_to(organisation_job_path(vacancy.id))
        end

        context "when the vacancy has not been published" do
          before { vacancy.update(status: "draft") }

          it "redirects to the review page" do
            expect(request).to redirect_to(organisation_job_review_path(vacancy.id))
          end
        end
      end

      context "when all steps are not valid" do
        before do
          allow_any_instance_of(Publishers::Vacancies::BaseController).to receive(:all_steps_valid?).and_return(false)
          allow_any_instance_of(Publishers::Vacancies::BaseController).to receive(:next_invalid_step).and_return(:school_visits)
        end

        it "redirects to the next invalid step" do
          expect(request).to redirect_to(organisation_job_build_path(vacancy.id, :school_visits))
        end
      end

      context "when save and finish later has been clicked" do
        let(:request) do
          post organisation_job_application_forms_path(vacancy.id), params: {
            publishers_job_listing_application_form_form: {
              application_form: valid_file,
              application_email: application_email,
            },
            save_and_finish_later: "true",
          }
        end

        it "redirects to the next invalid step" do
          expect(request).to redirect_to(organisation_job_path(vacancy.id))
        end
      end

      context "when only the application email has been changed" do
        let(:vacancy) { create(:vacancy, :with_application_form, enable_job_applications: false, receive_applications: "email", organisations: [organisation]) }
        let(:request) do
          post organisation_job_application_forms_path(vacancy.id), params: {
            publishers_job_listing_application_form_form: {
              application_form: nil,
              application_email: application_email,
            },
          }
        end

        it "does not send a supporting_document_created event" do
          expect { request }.to_not have_triggered_event(:supporting_document_created)
        end
      end
    end

    context "when the form is invalid" do
      let(:request) do
        post organisation_job_application_forms_path(vacancy.id), params: {
          publishers_job_listing_application_form_form: {
            application_form: nil,
            application_email: nil,
          },
        }
      end

      it "renders the application form step" do
        expect(request).to render_template("publishers/vacancies/build/application_form")
      end
    end

    context "when an application form has been staged for replacement" do
      context "when a replacement application form has been provided" do
        let(:vacancy) { create(:vacancy, :with_application_form, enable_job_applications: false, receive_applications: "email", organisations: [organisation]) }
        let(:old_file) { vacancy.application_form }
        let(:replacement_file) { fixture_file_upload("blank_job_spec.pdf") }
        let(:request) do
          post organisation_job_application_forms_path(vacancy.id), params: {
            publishers_job_listing_application_form_form: {
              application_form: replacement_file,
              application_email: "test@example.com",
              application_form_staged_for_replacement: true,
            },
          }
        end

        before do
          allow_any_instance_of(Publishers::Vacancies::BaseController).to receive(:all_steps_valid?).and_return(false)
          allow_any_instance_of(Publishers::Vacancies::BaseController).to receive(:next_invalid_step).and_return(:school_visits)
        end

        it "replaces the old file with the new file" do
          old_file_id = vacancy.application_form.id

          request

          expect(vacancy.reload.application_form.id).not_to eq(old_file_id)
        end

        it "sends a supporting_document_replaced event" do
          expect { request }
            .to have_triggered_event(:supporting_document_replaced)
            .with_data(
              vacancy_id: vacancy.id,
              document_type: "application_form",
              name: "blank_job_spec.pdf",
              size: 28_527,
              content_type: "application/pdf",
            )
        end

        it "redirects to the next step" do
          expect(request).to redirect_to(organisation_job_build_path(vacancy.id, :school_visits))
        end
      end

      context "when a replacement application form has not been provided" do
        let(:hidden_field) do
          "<input value=\"true\" autocomplete=\"off\" type=\"hidden\" name=\"publishers_job_listing_application_form_form[application_form_staged_for_replacement]\" " \
          "id=\"publishers_job_listing_application_form_form_application_form_staged_for_replacement\" />"
        end
        let(:error_message) { I18n.t("activemodel.errors.models.publishers/job_listing/application_form_form.attributes.application_form.blank") }
        let(:request) do
          post organisation_job_application_forms_path(vacancy.id), params: {
            publishers_job_listing_application_form_form: {
              application_form: nil,
              application_email: "test@example.com",
              application_form_staged_for_replacement: true,
            },
          }
        end

        it "fails validation" do
          expect(request).to render_template("publishers/vacancies/build/application_form")
        end

        it "displays an error message" do
          request

          expect(response.body).to include(error_message)
        end

        it "adds the application_form_staged_for_replacement hidden field to the form" do
          request

          expect(response.body).to include(hidden_field)
        end
      end
    end

    context "MIME type inspection" do
      let(:valid_file_types) { "PDF, DOC or DOCX" }

      before do
        post organisation_job_application_forms_path(vacancy.id), params: {
          publishers_job_listing_application_form_form: { application_form: file },
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
          expect(response.body).not_to include(I18n.t("jobs.file_type_error_message", filename: "valid_word_document.docx", valid_file_types: valid_file_types))
        end
      end

      context "with a file with a valid extension but invalid 'real' MIME type" do
        let(:file) { fixture_file_upload("mime_types/zip_file_pretending_to_be_a_pdf.pdf") }

        it "is rejected even if the file extension suggests it is valid" do
          expect(response.body).to include(I18n.t("jobs.file_type_error_message", filename: "zip_file_pretending_to_be_a_pdf.pdf", valid_file_types: valid_file_types))
        end
      end

      context "with an invalid file type" do
        let(:file) { fixture_file_upload("mime_types/invalid_plain_text_file.txt") }

        it "is rejected even if the file extension suggests it is valid" do
          expect(response.body).to include(I18n.t("jobs.file_type_error_message", filename: "invalid_plain_text_file.txt", valid_file_types: valid_file_types))
        end
      end
    end
  end
end
