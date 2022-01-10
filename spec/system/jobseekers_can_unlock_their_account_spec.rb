require "rails_helper"

RSpec.describe "Jobseekers can unlock their account" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    visit root_path
    within("nav") { click_on I18n.t("buttons.sign_in") }
    click_on I18n.t("buttons.sign_in_jobseeker")
  end

  context "when the jobseeker has one sign-in attempt remaining" do
    before { jobseeker.update!(failed_attempts: Devise.maximum_attempts) }

    scenario "they receive an email with unlocking instructions after their final failed attempt" do
      expect { sign_in_jobseeker(password: "wrong password") }.to change { delivered_emails.count }.by(1)

      expect(page).to have_content(I18n.t("jobseekers.sessions.locked.heading"))
    end
  end

  context "when the jobseeker's account is locked" do
    before do
      jobseeker.lock_access!
    end

    context "when the unlock token is invalid" do
      before do
        visit jobseeker_unlock_url(unlock_token: "invalid token")
        click_on "Confirm"
      end

      scenario "they are locked out of their account" do
        expect(jobseeker.reload).to be_access_locked

        expect(page).to have_content(I18n.t("jobseekers.unlocks.new.heading"))
      end

      scenario "they can request to be emailed the link again and use it to unlock their account" do
        fill_in "Email address", with: jobseeker.email

        expect {
          within(".new_jobseeker") { click_on I18n.t("jobseekers.unlocks.new.form_submit") }
        }.to change {
          delivered_emails.count
        }.by(1)

        confirm_email_address

        expect(jobseeker.reload).not_to be_access_locked

        expect(current_path).to eq(jobseeker_session_path)
        expect(page).to have_content(I18n.t("devise.unlocks.unlocked"))
      end
    end
  end
end
