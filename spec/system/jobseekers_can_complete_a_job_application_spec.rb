require "rails_helper"

RSpec.describe "Jobseekers can complete a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows jobseekers to complete application and go to review page" do
    visit jobseekers_job_application_build_path(job_application, :personal_details)
    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    fill_in "First name", with: "John"
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(jobseekers_job_application_review_path(job_application))
    expect(page).to have_content("First name: John")
  end
end
