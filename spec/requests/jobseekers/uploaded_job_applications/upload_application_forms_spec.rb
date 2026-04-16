# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Upload application forms" do
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:uploaded_job_application, :status_draft, :with_uploaded_application_form, jobseeker: jobseeker) }

  before { sign_in(jobseeker, scope: :jobseeker) }
  after { sign_out(jobseeker) }

  describe "PATCH #update" do
    context "when no new file is submitted but one is already attached and the existing file is malicious" do
      before do
        job_application.application_form.blob.malware_scan_malicious!
      end

      it "renders the edit template" do
        patch jobseekers_uploaded_job_application_upload_application_form_path(job_application),
              params: { jobseekers_uploaded_job_application_upload_application_form_form: { upload_application_form_section_completed: "true" } }

        expect(response).to render_template(:edit)
      end
    end
  end
end
