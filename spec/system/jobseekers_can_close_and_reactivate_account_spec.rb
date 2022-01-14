require "rails_helper"

RSpec.describe "Jobseekers can close and reactivate their account" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let!(:job_application) { create(:job_application, :reviewed, jobseeker: jobseeker, vacancy: vacancy) }
  let!(:subscription) { create(:subscription, email: jobseeker.email, active: true) }

  before { login_as(jobseeker, scope: :jobseeker) }

  it "allows closing and reactivating a jobseeker account" do
    visit jobseekers_account_path

    click_on I18n.t("jobseekers.accounts.show.close_account")

    choose "Other"
    fill_in "jobseekers_close_account_feedback_form[close_account_reason_comment]", with: "Worst service ever!!"

    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.registrations.destroy.success"))

    within("nav") { click_link I18n.t("buttons.sign_in") }
    click_on I18n.t("buttons.sign_in_jobseeker")
    sign_in_jobseeker(email: jobseeker.email, password: jobseeker.password)

    expect(current_path).to eq(jobseekers_job_applications_path)
  end
end
