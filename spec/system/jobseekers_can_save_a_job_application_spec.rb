require "rails_helper"

RSpec.describe "Jobseekers can save a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows jobseekers to save application and go to dashboard" do
    visit jobseekers_job_application_build_path(job_application, :personal_details)
    fill_in_personal_details
    and_it_saves_the_job_application
  end

  def save_as_draft
    click_on I18n.t("buttons.save_as_draft")
  end

  def and_it_saves_the_job_application
    expect { save_as_draft }.to change { JobApplication.first.application_data }.from(nil).to({ "first_name" => "John" })
    expect(current_path).to eq(jobseekers_saved_jobs_path)
    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.saved_job_application"))
  end
end
