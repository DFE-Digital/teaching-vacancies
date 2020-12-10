require "rails_helper"

RSpec.describe "Jobseekers can reset password" do
  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    allow(Jobseeker).to receive(:find_by).and_return(jobseeker)
  end

  context "when the password reset token is valid" do
    let(:jobseeker) { create(:jobseeker) }

    it "allows jobseekers to reset their password" do
      visit new_jobseeker_password_path
      click_on I18n.t("buttons.continue")

      expect(page).to have_content("There is a problem")

      fill_in "jobseeker[email]", with: jobseeker.email
      click_on I18n.t("buttons.continue")

      expect(page).to have_content I18n.t("jobseekers.passwords.check_your_email_password.title")

      raw_reset_password_token = devise_token_from_last_mail(:reset_password)
      reset_password_url = edit_jobseeker_password_url(reset_password_token: raw_reset_password_token)
      expect(last_email.body).to have_content(reset_password_url)

      visit reset_password_url
      click_on I18n.t("buttons.update_password")

      expect(page).to have_content("There is a problem")

      fill_in "jobseeker[password]", with: "NewPassword1234"
      click_on I18n.t("buttons.update_password")

      expect(page).to have_content(I18n.t("devise.passwords.updated"))
    end
  end

  context "when the password reset token is expired" do
    let(:jobseeker) { create(:jobseeker, reset_password_sent_at: 3.hours.ago) }

    it "shows an expired request page" do
      visit new_jobseeker_password_path
      fill_in "jobseeker[email]", with: jobseeker.email
      click_on I18n.t("buttons.continue")
      travel_to 3.hours.from_now
      raw_reset_password_token = devise_token_from_last_mail(:reset_password)
      reset_password_url = edit_jobseeker_password_url(reset_password_token: raw_reset_password_token)
      visit reset_password_url

      expect(page).to have_content(I18n.t("jobseekers.passwords.expired_token.title"))

      click_on I18n.t("buttons.resend_email")

      expect(delivered_emails.count).to eq(2)
    end
  end
end
