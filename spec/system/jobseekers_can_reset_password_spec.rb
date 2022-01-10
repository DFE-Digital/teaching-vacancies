require "rails_helper"

RSpec.describe "Jobseekers can reset password" do
  let(:jobseeker) { create(:jobseeker) }

  context "when the password reset token is valid" do
    it "allows jobseekers to reset their password" do
      visit new_jobseeker_password_path
      click_on I18n.t("buttons.continue")

      expect(page).to have_content("There is a problem")

      fill_in "jobseeker[email]", with: jobseeker.email
      click_on I18n.t("buttons.continue")

      expect(page).to have_content I18n.t("jobseekers.passwords.check_your_email_password.title")

      confirm_email_address

      click_on I18n.t("buttons.update_password")

      expect(page).to have_content("There is a problem")

      fill_in "jobseeker[password]", with: "NewPassword1234"
      click_on I18n.t("buttons.update_password")

      expect(page).to have_content(I18n.t("devise.passwords.updated"))
    end
  end

  context "when the password reset token is expired" do
    it "shows an expired request page" do
      visit new_jobseeker_password_path
      fill_in "jobseeker[email]", with: jobseeker.email
      click_on I18n.t("buttons.continue")
      travel_to(3.hours.from_now) do
        confirm_email_address

        expect(page).to have_content(I18n.t("jobseekers.passwords.expired_token.title"))

        click_on I18n.t("buttons.resend_email")

        expect(delivered_emails.count).to eq(2)
      end
    end
  end
end
