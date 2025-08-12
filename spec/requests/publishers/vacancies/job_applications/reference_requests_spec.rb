require "rails_helper"

RSpec.describe "Job applications reference request" do
  let(:vacancy) { create(:vacancy) }
  let(:organisation) { vacancy.organisations.first }
  let(:job_application) { create(:job_application, :status_submitted, vacancy:) }
  let(:referee) { create(:referee, job_application:) }
  let(:reference_request) do
    referee.create_reference_request!(token: SecureRandom.uuid, status: :received, email: referee.email)
  end
  let(:job_reference) { create(:job_reference, :reference_given, referee:) }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }

  before do
    reference_request
    job_reference
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "GET #show" do
    context "when request format is pdf" do
      it "returns the pdf file" do
        get(organisation_job_job_application_reference_request_path(vacancy.id, job_application.id, reference_request.id, format: :pdf))

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("inline")
        expect(response.headers["Content-Disposition"]).to include("reference_#{referee.id}.pdf")
      end
    end

    context "when requesting html" do
      it "renders the page" do
        get(organisation_job_job_application_reference_request_path(vacancy.id, job_application.id, reference_request.id))

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:show)
      end
    end
  end
end
