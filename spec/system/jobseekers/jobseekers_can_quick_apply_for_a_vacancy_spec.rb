require "rails_helper"

RSpec.describe "Jobseekers can quick apply for a job" do
  let(:jobseeker) { create(:jobseeker) }
  let(:old_vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let!(:recent_job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: old_vacancy) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit new_jobseekers_job_job_application_path(vacancy.id)
  end

  it "redirects to quick_apply page, starts application and redirects to review page" do
    expect(page).to have_current_path(new_quick_apply_jobseekers_job_job_application_path(vacancy.id), ignore_query: true)

    click_on I18n.t("buttons.start_application")

    expect(page).to have_current_path(jobseekers_job_application_review_path(jobseeker.job_applications.draft.first.id), ignore_query: true)
  end
end
