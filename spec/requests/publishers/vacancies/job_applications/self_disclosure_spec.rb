require "rails_helper"

RSpec.describe "Job applications self disclosure" do
  let(:vacancy) { create(:vacancy) }
  let(:organisation) { vacancy.organisations.first }
  let(:job_application) do
    create(:job_application, :status_submitted, vacancy:,
                                                self_disclosure_request: build(:self_disclosure_request, :sent, self_disclosure: build(:self_disclosure)))
  end
  let!(:self_disclosure_request) { job_application.self_disclosure_request }
  let!(:self_disclosure) { self_disclosure_request.self_disclosure }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "GET #show" do
    context "when request format is pdf" do
      it "returns the pdf file" do
        get(organisation_job_job_application_self_disclosure_path(vacancy.id, job_application.id, format: :pdf))

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("inline")
        expect(response.headers["Content-Disposition"]).to include("self_disclosure_#{self_disclosure.id}.pdf")
      end
    end

    context "when requesting html" do
      it "renders the page" do
        get(organisation_job_job_application_self_disclosure_path(vacancy.id, job_application.id))

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:show)
      end
    end
  end

  describe "PATCH #update" do
    let(:request) do
      patch(organisation_job_job_application_self_disclosure_path(vacancy.id, job_application.id))
    end

    it "redirects to job application" do
      expect(request)
        .to redirect_to(organisation_job_job_application_self_disclosure_path(vacancy.id, job_application.id))
    end

    it "updates request status" do
      expect { request }
        .to change { self_disclosure_request.reload.status }.from("sent").to("received_off_service")
    end
  end
end
