require "rails_helper"

RSpec.describe "Publishers::Vacancies::JobApplications::Notes" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let(:valid_note_params) { { note: { content: "Test note" } } }

  before do
    sign_in(publisher, scope: :publisher)
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
  end

  after { sign_out publisher }

  describe "POST /organisation/jobs/:vacancy_id/job_applications/:job_application_id/notes" do
    let(:notes_path) { organisation_job_job_application_notes_path(vacancy.id, job_application.id) }

    context "with return_to parameter" do
      let(:params) do
        valid_note_params.merge(return_to: "https://example.com/some/page")
      end

      it "redirects to the return_to URL" do
        post notes_path, params: params

        expect(response).to redirect_to("https://example.com/some/page")
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

    context "with return_to parameter" do
      let(:params) { { return_to: "https://example.com/some/page" } }

      it "redirects to the return_to URL" do
        delete note_path, params: params

        expect(response).to redirect_to("https://example.com/some/page")
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
