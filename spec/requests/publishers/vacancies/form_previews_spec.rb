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
    it "sends a plain PDF file" do
      get organisation_job_form_preview_path(vacancy.id, :plain)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/pdf")
    end

    it "sends a catholic PDF file" do
      get organisation_job_form_preview_path(vacancy.id, :catholic)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/pdf")
    end

    it "sends a religious PDF file" do
      get organisation_job_form_preview_path(vacancy.id, :religious)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/pdf")
    end
  end
end
