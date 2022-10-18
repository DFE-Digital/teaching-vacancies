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
    let(:vacancy) { create(:vacancy, :with_application_form, organisations: [organisation]) }

    context "create_application_form" do
      before do
        allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
      end

      it "triggers an event" do
        expect {
          post organisation_job_application_forms_path(vacancy.id), params: {
            publishers_job_listing_application_form_form: { application_form: fixture_file_upload("blank_job_spec.pdf", "application/pdf") },
          }
        }.to have_triggered_event(:supporting_document_created)
          .with_data(
            vacancy_id: anonymised_form_of(vacancy.id),
            document_type: "application_form",
            name: "blank_job_spec.pdf",
            size: 28_527,
            content_type: "application/pdf",
          )
      end

      context "MIME type inspection" do
        before do
          post organisation_job_application_forms_path(vacancy.id), params: {
            publishers_job_listing_application_form_form: { application_form: file },
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

    context "update_vacancy" do
      subject do
        post organisation_job_application_forms_path(vacancy.id), params: {
          publishers_job_listing_application_form_form: { application_email: application_email },
        }
      end

      let(:application_email) { "new_application_email@example.com" }

      context "when all steps are valid and complete" do
        before { subject }

        it "updates the vacancy" do
          expect(vacancy.reload.application_email).to eq application_email
        end

        it "redirects to the review page" do
          expect(response).to redirect_to(organisation_job_path(vacancy.id))
        end
      end

      context "when there is an invalid step" do
        let(:completed_steps_without_school_visits) { vacancy.completed_steps.excluding("school_visits") }

        before do
          vacancy.update(completed_steps: completed_steps_without_school_visits, school_visits: nil)
          subject
        end

        it "updates the vacancy" do
          expect(vacancy.reload.application_email).to eq application_email
        end

        context "when the vacancy is published" do
          it "redirects to the show page" do
            expect(response).to redirect_to(organisation_job_path(vacancy.id))
          end
        end

        context "when the vacancy is not published" do
          let(:vacancy) { create(:vacancy, :draft, :with_application_form, organisations: [organisation]) }

          it "redirects to the next invalid step" do
            expect(response).to redirect_to(organisation_job_build_path(vacancy.id, :school_visits))
          end
        end
      end

      context "when save and finish later has been clicked" do
        before do
          post organisation_job_application_forms_path(vacancy.id), params: {
            publishers_job_listing_application_form_form: { application_email: application_email },
            save_and_finish_later: "true",
          }
        end

        it "updates the vacancy" do
          expect(vacancy.reload.application_email).to eq application_email
        end

        it "redirects to the review page" do
          expect(response).to redirect_to(organisation_job_path(vacancy.id))
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:vacancy) { create(:vacancy, :with_application_form, organisations: [organisation]) }
    let(:application_form) { vacancy.application_form }

    it "triggers an event" do
      expect {
        delete organisation_job_application_forms_path(id: application_form.id, job_id: vacancy.id)
      }.to have_triggered_event(:supporting_document_deleted)
        .with_data(
          vacancy_id: anonymised_form_of(vacancy.id),
          document_type: "application_form",
          name: "blank_job_spec.pdf",
          size: 28_527,
          content_type: "application/pdf",
        )
    end

    it "removes the application form" do
      delete organisation_job_application_forms_path(id: application_form.id, job_id: vacancy.id)
      follow_redirect!

      expect(response.body).to include(I18n.t("jobs.file_delete_success_message", filename: application_form.filename))
      expect(vacancy.reload.application_form).not_to be_present
    end
  end
end
