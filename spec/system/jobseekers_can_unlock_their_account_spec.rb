require "rails_helper"

RSpec.describe "Jobseekers can unlock their account" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    visit root_path
    within(".navbar-component") do
      click_on I18n.t("buttons.sign_in")
    end
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
      before { visit unlock_url(jobseeker, unlock_token: "invalid token") }

      scenario "they are locked out of their account" do
        expect(jobseeker.reload).to be_access_locked

        expect(page).to have_content(I18n.t("jobseekers.unlocks.new.heading"))
      end

      scenario "they can request to be emailed the link again and use it to unlock their account" do
        expect { resend_unlock_instructions_email }.to change { delivered_emails.count }.by(1)

        visit first_link_from_last_mail

        expect(jobseeker.reload).not_to be_access_locked

        expect(current_path).to eq(jobseeker_session_path)
        expect(page).to have_content(I18n.t("devise.unlocks.unlocked"))
      end
    end
  end
end
