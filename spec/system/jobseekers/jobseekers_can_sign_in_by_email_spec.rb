require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "Jobseekers can sign in with fallback email authentication" do
  before { allow(AuthenticationFallbackForJobseekers).to receive(:enabled?).and_return(true) }

  it "can reach email authentication page" do
    visit root_path
    within(".govuk-header__navigation") { click_on I18n.t("buttons.sign_in") }
    click_on I18n.t("buttons.sign_in_jobseeker")

    expect(page).to have_content(I18n.t("publishers.login_keys.new.notice"))
  end

  context "when fallback authentication is enabled" do
    let(:jobseeker) { create(:jobseeker, confirmed_at: 1.day.ago) }

    let(:login_key) do
      EmergencyLoginKey.create(owner: jobseeker, not_valid_after: Time.current + Jobseekers::LoginKeysController::EMERGENCY_LOGIN_KEY_DURATION)
    end

    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow_any_instance_of(Jobseekers::LoginKeysController)
        .to receive(:generate_login_key)
        .with(jobseeker: jobseeker)
        .and_return(login_key)
      allow(Jobseekers::AuthenticationFallbackMailer).to receive(:sign_in_fallback)
        .with(login_key_id: login_key.id, jobseeker: jobseeker)
        .and_return(message_delivery)
    end

    context "when a jobseeker tries to sign in" do
      it "can sign in, sign out" do
        freeze_time do
          visit root_path
          within(".govuk-header__navigation") { click_on I18n.t("buttons.sign_in") }
          click_on I18n.t("buttons.sign_in_jobseeker")

          # Expect to send an email
          expect(message_delivery).to receive(:deliver_later)

          fill_in "jobseeker[email]", with: jobseeker.email
          click_on I18n.t("buttons.submit")
          expect(page).to have_content(I18n.t("publishers.temp_login.check_your_email.sent"))

          # Expect that the link in the email goes to the landing page
          visit consume_jobseekers_login_key_path(login_key)

          expect(page).to have_content("Saved jobs")
          expect(page).to have_current_path(jobseeker_root_path)

          expect(:jobseeker_sign_in_attempt).to have_been_enqueued_as_analytics_events

          # Can sign out
          click_on(I18n.t("nav.sign_out"))
          expect(page).to have_current_path(new_jobseekers_login_key_path)
          expect(page).to have_content("Jobseeker sign in")

          within(".govuk-header__navigation") { expect(page).to have_content(I18n.t("buttons.sign_in")) }

          # Login link no longer works
          visit consume_jobseekers_login_key_path(login_key)
          expect(page).to have_content("used")
          expect(page).to have_content("Sign in unsuccessful")
          expect(page).to have_no_current_path(jobseeker_root_path)
        end
      end

      it "cannot sign in if key has expired" do
        visit root_path
        within(".govuk-header__navigation") { click_on I18n.t("buttons.sign_in") }
        click_on I18n.t("buttons.sign_in_jobseeker")
        expect(message_delivery).to receive(:deliver_later)
        fill_in "jobseeker[email]", with: jobseeker.email
        click_on I18n.t("buttons.submit")
        travel 5.hours do
          visit consume_jobseekers_login_key_path(login_key)
          expect(page).to have_content("expired")
          expect(page).to have_content("Sign in unsuccessful")
        end
      end
    end
  end
end
