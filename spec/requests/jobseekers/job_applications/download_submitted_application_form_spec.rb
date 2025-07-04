require "rails_helper"

RSpec.describe "Download submitted application form" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy) }
  let(:job_application) { create(:uploaded_job_application, jobseeker: jobseeker, vacancy: vacancy, status: :submitted) }

  before { sign_in(jobseeker, scope: :jobseeker) }

  context "when the application form is attached" do
    before do
      job_application.application_form.attach(
        io: Rails.root.join("spec/fixtures/files/blank_job_spec.pdf").open,
        filename: "application_form.pdf",
        content_type: "application/pdf",
      )
    end

    it "sends the application form file" do
      get download_submitted_form_jobseekers_uploaded_job_application_upload_application_form_path(job_application)

      expect(response).to be_successful
      expect(response.body).to include("%PDF")
      expect(response.content_type).to eq("application/pdf")
    end
  end

  context "when the application form is not attached" do
    it "redirects to the job application page" do
      get download_submitted_form_jobseekers_uploaded_job_application_upload_application_form_path(job_application)

      expect(response).to redirect_to(jobseekers_job_applications_path)
    end
  end

  context "when the jobseeker is not the owner of the job application" do
    let(:other_jobseeker) { create(:jobseeker) }

    before do
      sign_out jobseeker
      sign_in other_jobseeker, scope: :jobseeker
    end

    it "redirects with an authorization error" do
      get download_submitted_form_jobseekers_uploaded_job_application_upload_application_form_path(job_application)

      expect(response).to redirect_to(jobseekers_job_applications_path)
      expect(flash[:alert]).to eq("You are not authorized to download this file.")
    end
  end
end
