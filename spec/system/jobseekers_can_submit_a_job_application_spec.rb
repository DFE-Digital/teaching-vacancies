require "rails_helper"

RSpec.describe "Jobseekers can submit a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: organisation }]) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  context "when the application is complete" do
    let(:job_application) { create(:job_application, :complete, jobseeker: jobseeker, vacancy: vacancy) }

    it "allows jobseekers to submit application and go to confirmation page" do
      visit jobseekers_job_application_review_path(job_application)

      click_on I18n.t("buttons.submit_application")
      expect(page).to have_content("There is a problem")

      check "Confirm data accurate"
      check "Confirm data usage"

      expect { click_on I18n.t("buttons.submit_application") }
        .to change { JobApplication.first.status }.from("draft").to("submitted")
      expect(page).to have_content(I18n.t("jobseekers.job_applications.submit.panel.title"))
    end
  end

  context "when the application is incomplete" do
    let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

    it "does not allow jobseekers to submit application and go to confirmation page" do
      visit jobseekers_job_application_review_path(job_application)

      check "Confirm data accurate"
      check "Confirm data usage"

      click_on I18n.t("buttons.submit_application")

      expect(JobApplication.first.status).to eq("draft")
      expect(page).to have_content("There is a problem")
    end

    it "allows jobseekers to save application and go to dashboard" do
      visit jobseekers_job_application_review_path(job_application)

      click_on I18n.t("buttons.save_as_draft")

      expect(JobApplication.first.status).to eq("draft")
      expect(page).to have_content("Application saved as draft")
      expect(current_path).to eq(jobseeker_root_path)
    end
  end
end
