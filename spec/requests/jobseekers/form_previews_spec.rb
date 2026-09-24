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
      expect(response.body).to include("Professional status")
      expect(response.body).to include("Do you have qualified teacher status (QTS)?")
      expect(response.body).to include("Age range and subject")
      expect(response.body).to include("Teacher reference number (TRN)")
      expect(response.body).to include("Have you completed your induction period?")
      expect(response.body).to include("Qualifications")
      expect(response.body).to include("Postgraduate qualification")
      expect(response.body).to include("Undergraduate degree")
      expect(response.body).to include("A levels")
      expect(response.body).to include("GCSEs")
      expect(Capybara.string(response.body)).to have_css(".print-qualification", count: 10)
      expect(response.body).to include("Training and continuing professional development (CPD)")
      expect(response.body).to include("Course length")
      expect(Capybara.string(response.body)).to have_css(".print-training-record", count: 2)
      expect(response.body).to include("Professional body memberships")
      expect(response.body).to include("Membership or registration number:")
      expect(Capybara.string(response.body)).to have_css(".print-membership-record", count: 2)
      expect(response.body).to include("Work history")
      expect(response.body).to include("Employment currently held:")
      expect(response.body).to include("Reason for leaving:")
      expect(Capybara.string(response.body)).to have_css(".print-employment-record", count: 5)
      expect(response.body).to include("Personal statement")
      expect(Capybara.string(response.body)).to have_css(".print-personal-statement__writing-space", count: 1)
    end
  end
end
