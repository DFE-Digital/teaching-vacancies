# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publishers::Vacancies::FormPreviewController" do
  let(:vacancy) { create(:vacancy) }
  let(:organisation) { vacancy.organisations.first }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "GET #show" do
    context "when job_application" do
      %i[plain catholic religious].each do |sample|
        it "sends a #{sample} PDF file" do
          get organisation_job_form_preview_path(vacancy.id, sample)

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq("application/pdf")
          expect(response.body).to include("%PDF")
          expect(response.headers["Content-Disposition"]).to include(/job_application_\d+\.pdf/)
        end
      end
    end

    it "sends a self-disclosure PDF file" do
      get organisation_job_form_preview_path(vacancy.id, :self_disclosure)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/pdf")
      expect(response.body).to include("%PDF")
      expect(response.headers["Content-Disposition"]).to include(/self_disclosure_\d+\.pdf/)
    end

    it "sends a job reference PDF file" do
      get organisation_job_form_preview_path(vacancy.id, :job_reference)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/pdf")
      expect(response.body).to include("%PDF")
      expect(response.headers["Content-Disposition"]).to include(/job_reference_\d+\.pdf/)
    end
  end
end
