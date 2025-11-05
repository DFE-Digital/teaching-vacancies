# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Jobseekers::FormPreviewController" do
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_withdrawn, jobseeker:) }

  before { sign_in(jobseeker, scope: :jobseeker) }

  after { sign_out(jobseeker) }

  describe "GET #show" do
    it "sends a blank job application PDF file" do
      get jobseekers_job_application_form_preview_path(job_application, :blank)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/pdf")
      expect(response.body).to include("%PDF")
      expect(response.headers["Content-Disposition"]).to include(/job_application_\d+\.pdf/)
    end
  end
end
