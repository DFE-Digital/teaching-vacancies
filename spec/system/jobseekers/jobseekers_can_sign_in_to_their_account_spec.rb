require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.shared_examples "a sign in attempt" do
  it "triggers a `jobseeker_sign_in_attempt` event" do
    sign_in_jobseeker(email: email, password: password)
    expect(:jobseeker_sign_in_attempt).to have_been_enqueued_as_analytics_events
  end
end

RSpec.describe "Jobseekers can sign in to their account" do
  let(:jobseeker) { create(:jobseeker) }
  let(:expected_data) do
    {
      email_identifier: anonymised_form_of(reported_email),
      success: successful_attempt?,
      errors: sign_in_errors,
    }
  end

  let(:reported_email) { nil }

  before do
    visit root_path
    within(".govuk-header__navigation") { click_on I18n.t("buttons.sign_in") }
    click_on I18n.t("buttons.sign_in_jobseeker")
  end

  context "when entering correct details" do
    let(:email) { jobseeker.email }
    let(:password) { jobseeker.password }
    let(:successful_attempt?) { "true" }
    let(:sign_in_errors) { nil }
    let(:reported_email) { email }

    it "signs in the jobseeker" do
      sign_in_jobseeker(email: email, password: password)
      expect(current_path).to eq(jobseeker_root_path)
    end

    include_examples "a sign in attempt"
  end

  context "when entering incorrect details" do
    let(:successful_attempt?) { "false" }
    let(:sign_in_errors) { anything }

    context "when details are missing" do
      let(:email) { "" }
      let(:password) { "" }

      it "does not sign in the jobseeker and displays an error message" do
        sign_in_jobseeker(email: email, password: password)
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).to have_content(I18n.t("devise.failure.blank"))
      end

      include_examples "a sign in attempt"
    end

    context "when the account does not exist" do
      let(:email) { "fake@example.net" }
      let(:password) { jobseeker.password }

      it "does not sign in the jobseeker and displays a general error message" do
        sign_in_jobseeker(email: email, password: password)
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).to have_content(I18n.t("devise.failure.invalid"))
      end

      include_examples "a sign in attempt"
    end

    context "when the password is incorrect" do
      let(:email) { jobseeker.email }
      let(:password) { "incorrect_password" }

      it "does not sign in the jobseeker and displays a general error message" do
        sign_in_jobseeker(email: email, password: password)
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).to have_content(I18n.t("devise.failure.invalid"))
      end

      include_examples "a sign in attempt"
    end
  end

  context "when entering incorrect details followed by correct detail" do
    let(:email) { jobseeker.email }
    let(:password) { "incorrect_password" }

    include_examples "a sign in attempt"
  end
end
