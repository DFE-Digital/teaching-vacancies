require "rails_helper"

RSpec.describe "Publishers::Vacancies::JobApplications::Notes" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let(:valid_note_params) { { publishers_job_application_notes_form: { content: "Test note" } } }

  before do
    sign_in(publisher, scope: :publisher)
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
  end

  after { sign_out publisher }

  describe "POST /organisation/jobs/:vacancy_id/job_applications/:job_application_id/notes" do
    let(:notes_path) { organisation_job_job_application_notes_path(vacancy.id, job_application.id) }

    context "with return_to parameter for reference_request" do
      let(:referee) { create(:referee, job_application: job_application) }
      let(:reference_request) { create(:reference_request, referee: referee) }

      before do
        create(:job_reference, referee: referee)
      end

      context "with valid reference_request_id" do
        let(:params) do
          valid_note_params.merge(
            return_to: "reference_request",
            reference_request_id: reference_request.id,
          )
        end

        it "redirects to the reference request page" do
          post notes_path, params: params

          expect(response).to redirect_to(
            organisation_job_job_application_reference_request_path(vacancy.id, job_application.id, reference_request.id),
          )
        end
      end

      context "without reference_request_id" do
        let(:params) do
          valid_note_params.merge(return_to: "reference_request")
        end

        it "redirects to the job application page" do
          post notes_path, params: params

          expect(response).to redirect_to(
            organisation_job_job_application_path(vacancy.id, job_application.id),
          )
        end
      end
    end

    context "with return_to parameter for self_disclosure" do
      let(:params) do
        valid_note_params.merge(return_to: "self_disclosure")
      end

      before do
        create(:self_disclosure_request, job_application: job_application)
      end

      it "redirects to the self disclosure page" do
        post notes_path, params: params

        expect(response).to redirect_to(
          organisation_job_job_application_self_disclosure_path(vacancy.id, job_application.id),
        )
      end
    end

    context "with unknown return_to parameter" do
      let(:params) do
        valid_note_params.merge(return_to: "unknown_page")
      end

      it "redirects to the job application page" do
        post notes_path, params: params

        expect(response).to redirect_to(
          organisation_job_job_application_path(vacancy.id, job_application.id),
        )
      end
    end

    context "without return_to parameter" do
      let(:params) { valid_note_params }

      it "redirects to the job application page" do
        post notes_path, params: params

        expect(response).to redirect_to(
          organisation_job_job_application_path(vacancy.id, job_application.id),
        )
      end
    end
  end

  describe "DELETE /organisation/jobs/:vacancy_id/job_applications/:job_application_id/notes/:id" do
    let!(:note) { create(:note, job_application: job_application, publisher: publisher) }
    let(:note_path) { organisation_job_job_application_note_path(vacancy.id, job_application.id, note.id) }

    context "with return_to parameter for reference_request" do
      let(:referee) { create(:referee, job_application: job_application) }
      let(:reference_request) { create(:reference_request, referee: referee) }

      before do
        create(:job_reference, referee: referee)
      end

      context "with valid reference_request_id" do
        let(:params) do
          {
            return_to: "reference_request",
            reference_request_id: reference_request.id,
          }
        end

        it "redirects to the reference request page" do
          delete note_path, params: params

          expect(response).to redirect_to(
            organisation_job_job_application_reference_request_path(vacancy.id, job_application.id, reference_request.id),
          )
        end
      end

      context "without reference_request_id" do
        let(:params) { { return_to: "reference_request" } }

        it "redirects to the job application page" do
          delete note_path, params: params

          expect(response).to redirect_to(
            organisation_job_job_application_path(vacancy.id, job_application.id),
          )
        end
      end
    end

    context "with return_to parameter for self_disclosure" do
      let(:params) { { return_to: "self_disclosure" } }

      before do
        create(:self_disclosure_request, job_application: job_application)
      end

      it "redirects to the self disclosure page" do
        delete note_path, params: params

        expect(response).to redirect_to(
          organisation_job_job_application_self_disclosure_path(vacancy.id, job_application.id),
        )
      end
    end

    context "with unknown return_to parameter" do
      let(:params) { { return_to: "unknown_page" } }

      it "redirects to the job application page" do
        delete note_path, params: params

        expect(response).to redirect_to(
          organisation_job_job_application_path(vacancy.id, job_application.id),
        )
      end
    end

    context "without return_to parameter" do
      it "redirects to the job application page" do
        delete note_path

        expect(response).to redirect_to(
          organisation_job_job_application_path(vacancy.id, job_application.id),
        )
      end
    end
  end
end
