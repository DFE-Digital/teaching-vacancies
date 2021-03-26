require "rails_helper"

RSpec.describe "Jobseekers can save a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:job_application) { create(:job_application, :status_draft, vacancy: vacancy, jobseeker: jobseeker) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows jobseekers to save application and go to dashboard" do
    visit jobseekers_job_application_build_path(job_application, :personal_details)

    fill_in "First name", with: "Steve"

    expect { click_on I18n.t("buttons.save_and_come_back") }
      .to change { job_application.reload.first_name }.from("").to("Steve")

    expect(current_path).to eq(jobseekers_job_applications_path)
    expect(page).to have_content(I18n.t("messages.jobseekers.job_applications.saved"))
  end
end
