require "rails_helper"

RSpec.describe "Jobseekers can register" do
  let(:email) { "jobseeker@example.com" }

  it "allows jobseekers to reset their password" do
    visit root_path
    find(:xpath, "//a[@href='/jobseekers/sign_up']").click
    fill_in "jobseeker[email]", with: email
    fill_in "jobseeker[password]", with: "Jobseeker1234"
    click_on I18n.t("buttons.create_account")

    expect(page).to have_content I18n.t("jobseekers.registrations.check_your_email.title")
    expect(page).to have_content email

    click_on I18n.t("jobseekers.registrations.check_your_email.resend_link"), visible: false
    visit first_link_from_last_mail
    click_on "Confirm"

    expect(current_path).to eq jobseekers_saved_jobs_path
  end
end
