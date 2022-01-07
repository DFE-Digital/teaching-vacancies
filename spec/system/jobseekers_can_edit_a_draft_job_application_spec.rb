require "rails_helper"

RSpec.describe "Jobseekers can edit a draft job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, first_name: "Steve", jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  it "allows jobseekers to edit job application from review page" do
    visit jobseekers_job_application_review_path(job_application)

    within ".review-component__section#personal_details" do
      click_on "Change"
    end

    expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :personal_details))

    fill_in "First name", with: "Dave"

    expect { click_on I18n.t("buttons.save") }.to change { job_application.reload.first_name }.from("Steve").to("Dave")

    expect(current_path).to eq(jobseekers_job_application_review_path(job_application))
    expect(page).to have_content(I18n.t("messages.jobseekers.job_applications.saved"))
  end
end
