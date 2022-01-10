require "rails_helper"

RSpec.describe "Jobseekers can withdraw a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let!(:job_application) { create(:job_application, :status_submitted, jobseeker:, vacancy:) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_path(job_application)
    click_on I18n.t("buttons.withdraw_application")
  end

  it "submits the form, renders error, withdraws the application and redirects to the dashboard with success message" do
    click_on I18n.t("buttons.withdraw_application")

    expect(page).to have_content("There is a problem")

    choose "jobseekers-job-application-withdraw-form-withdraw-reason-other-field"
    click_on I18n.t("buttons.withdraw_application")

    expect(current_path).to eq(jobseekers_job_applications_path)
    expect(page).to have_content(I18n.t("jobseekers.job_applications.withdraw.success", job_title: vacancy.job_title))
  end
end
