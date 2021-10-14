require "rails_helper"

RSpec.describe "Jobseekers can delete a draft job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  it "allows deleting the draft permanently" do
    visit jobseekers_job_applications_path

    click_on I18n.t("buttons.delete")
    click_on I18n.t("jobseekers.job_applications.confirm_destroy.confirm")

    expect(page).to have_content(I18n.t("messages.jobseekers.job_applications.draft_deleted", job_title: vacancy.job_title))
    expect(JobApplication.count).to be_zero
  end
end
