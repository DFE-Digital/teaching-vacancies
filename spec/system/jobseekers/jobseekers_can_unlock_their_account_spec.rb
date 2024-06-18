require "rails_helper"

RSpec.describe "Jobseekers can unlock their account" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    visit root_path
    within(".govuk-header__navigation") { click_on I18n.t("buttons.sign_in") }
    click_on I18n.t("buttons.sign_in_jobseeker")
  end

  context "when the jobseeker has one sign-in attempt remaining" do
    before { jobseeker.update!(failed_attempts: Devise.maximum_attempts) }

    it "they can unlock their account following the unlock email instructions received after their final failed attempt" do
      expect { sign_in_jobseeker(password: "wrong password") }.to change(delivered_emails, :count).by(1)

      expect(page).to have_content("too many attempts")

      visit first_link_from_last_mail
      expect(page).to have_css("h1", text: I18n.t("jobseekers.unlocks.show.title"))

      click_on I18n.t("jobseekers.unlocks.show.confirm")
      expect(jobseeker.reload).not_to be_access_locked
      expect(page).to have_css("h1", text: I18n.t("jobseekers.sessions.new.title"))
      expect(page).to have_content(I18n.t("devise.unlocks.unlocked"))
    end

    it "following the unlock link for a second time takes them directly to an error page" do
      sign_in_jobseeker(password: "wrong password")
      visit first_link_from_last_mail
      click_on I18n.t("jobseekers.unlocks.show.confirm")

      visit first_link_from_last_mail
      expect(page).to have_css("h1", text: I18n.t("jobseekers.unlocks.new.heading"))
      expect(page).to have_content(I18n.t("jobseekers.unlocks.new.description"))
    end
  end

  context "when the jobseeker's account is locked" do
    before do
      jobseeker.lock_access!
    end

    context "when the unlock token is invalid" do
      before do
        visit jobseeker_unlock_url(unlock_token: "invalid token")
      end

      it "they are locked out of their account" do
        expect(jobseeker.reload).to be_access_locked

        expect(page).to have_content(I18n.t("jobseekers.unlocks.new.heading"))
      end

      it "they can request to be emailed the link again and use it to unlock their account" do
        fill_in "Email address", with: jobseeker.email

        expect {
          within(".new_jobseeker") { click_on I18n.t("jobseekers.unlocks.new.form_submit") }
        }.to change(delivered_emails, :count).by(1)

        visit first_link_from_last_mail
        expect(page).to have_css("h1", text: I18n.t("jobseekers.unlocks.show.title"))
        click_on I18n.t("jobseekers.unlocks.show.confirm")

        expect(jobseeker.reload).not_to be_access_locked

        expect(page).to have_current_path(jobseeker_session_path, ignore_query: true)
        expect(page).to have_content(I18n.t("devise.unlocks.unlocked"))
      end
    end
  end
end
