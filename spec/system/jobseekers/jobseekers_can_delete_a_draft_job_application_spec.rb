require "rails_helper"

RSpec.describe "Jobseekers can delete a draft job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_applications_path
    click_on job_application.vacancy.job_title
  end

  after { logout }

  it "allows deleting the draft permanently" do
    click_on I18n.t("buttons.delete_application")
    expect { click_on I18n.t("jobseekers.job_applications.confirm_destroy.confirm") }.to change(JobApplication, :count).by(-1)

    expect(page).to have_content(I18n.t("messages.jobseekers.job_applications.draft_deleted", job_title: vacancy.job_title))
  end
end
