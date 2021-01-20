require "rails_helper"

RSpec.describe "Jobseekers can submit a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy) }
  let(:job_application) { create(:job_application, :complete, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows jobseekers to submit application and go to confirmation page" do
    visit jobseekers_job_application_review_path(job_application)
    expect { click_on I18n.t("buttons.submit_application") }
      .to change { JobApplication.first.status }.from("draft").to("submitted")
    expect(page).to have_content(I18n.t("jobseekers.job_applications.submit.title"))
  end
end
