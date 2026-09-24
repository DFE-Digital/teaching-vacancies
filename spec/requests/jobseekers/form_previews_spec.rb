# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Jobseekers::FormPreviewController" do
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_withdrawn, jobseeker:) }

  before { sign_in(jobseeker, scope: :jobseeker) }

  after { sign_out(jobseeker) }

  describe "GET #show" do
    it "renders the blank application title as HTML" do
      get jobseekers_job_application_form_preview_path(job_application, :blank)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/html")
      expect(response).to render_template(layout: "print")
      expect(response.body).to include("Blank application form")
      expect(response.body).to include(job_application.vacancy.job_title)
      expect(response.body).to include(job_application.vacancy.organisation_name)
      expect(response.body).to include("print-header__applicant-name")
      expect(response.body).to include("TVS-logo")
      expect(response.body).to include("In submitting this application, the candidate has consented")
      expect(response.body).to include("Personal details")
      expect(response.body).to include("First name")
      expect(response.body).to include("Working pattern preference details")
      expect(response.body.scan("print-table__writing-space").count).to eq(10)
    end
  end
end
