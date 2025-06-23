require "rails_helper"

RSpec.describe "Jobseekers can delete a draft job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  after { logout }

  it "allows deleting the draft permanently" do
    expect(JobApplication.count).to eq 1
    visit jobseekers_job_applications_path

    click_on job_application.vacancy.job_title
    click_on I18n.t("buttons.delete_application")
    click_on I18n.t("jobseekers.job_applications.confirm_destroy.confirm")

    expect(page).to have_content(I18n.t("messages.jobseekers.job_applications.draft_deleted", job_title: vacancy.job_title))
    expect(JobApplication.count).to be_zero
  end
end
