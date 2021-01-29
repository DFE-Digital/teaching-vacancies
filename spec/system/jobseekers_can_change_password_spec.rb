require "rails_helper"

RSpec.describe "Jobseekers can change password" do
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com", password: "password1234") }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
    visit edit_jobseeker_registration_path(update_password: true)
  end

  it "changes the password" do
    click_on I18n.t("buttons.update_password")

    expect(page).to have_content("There is a problem")

    fill_in "jobseeker[current_password]", with: "password1234"
    fill_in "jobseeker[password]", with: "4321newpass"
    click_on I18n.t("buttons.update_password")

    expect(page).to have_content I18n.t("devise.passwords.updated")
  end
end
