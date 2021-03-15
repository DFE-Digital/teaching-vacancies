require "rails_helper"

RSpec.describe "Jobseekers can sign in to their account" do
  let(:jobseeker) { create(:jobseeker) }
  let(:expected_data) do
    {
      email_identifier: anonymised_form_of(email),
      success: successful_attempt?,
      errors: sign_in_errors,
    }
  end

  before do
    visit root_path
    within(".navbar-component") do
      click_on I18n.t("buttons.sign_in")
    end
  end

  context "when entering correct details" do
    let(:email) { jobseeker.email }
    let(:password) { jobseeker.password }
    let(:successful_attempt?) { "true" }
    let(:sign_in_errors) { nil }

    it "signs in the jobseeker" do
      sign_in_jobseeker(email: email, password: password)
      expect(current_path).to eq(jobseeker_root_path)
      expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
    end

    it "triggers a successful `jobseeker_sign_in_attempt` event" do
      expect { sign_in_jobseeker(email: email, password: password) }
        .to have_triggered_event(:jobseeker_sign_in_attempt)
        .with_data(expected_data)
    end
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
        expect(page).not_to have_selector(".govuk-notification")
        expect(page).to have_content(I18n.t("activerecord.errors.models.jobseeker.attributes.email.blank"))
        expect(page).to have_content(I18n.t("activerecord.errors.models.jobseeker.attributes.password.blank"))
      end

      it "triggers an unsuccessful `jobseeker_sign_in_attempt` event" do
        expect { sign_in_jobseeker(email: email, password: password) }
          .to have_triggered_event(:jobseeker_sign_in_attempt)
          .with_data(expected_data)
      end
    end

    context "when the account does not exist" do
      let(:email) { "fake@email.com" }
      let(:password) { jobseeker.password }

      it "does not sign in the jobseeker and displays a general error message" do
        sign_in_jobseeker(email: email, password: password)
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).not_to have_selector(".govuk-notification")
        expect(page).to have_content(I18n.t("devise.failure.invalid"))
      end

      it "triggers an unsuccessful `jobseeker_sign_in_attempt` event" do
        expect { sign_in_jobseeker(email: email, password: password) }
          .to have_triggered_event(:jobseeker_sign_in_attempt)
          .with_data(expected_data)
      end
    end

    context "when the password is incorrect" do
      let(:email) { jobseeker.email }
      let(:password) { "incorrect_password" }

      it "does not sign in the jobseeker and displays a general error message" do
        sign_in_jobseeker(email: email, password: password)
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).not_to have_selector(".govuk-notification")
        expect(page).to have_content(I18n.t("devise.failure.invalid"))
      end

      it "triggers an unsuccessful `jobseeker_sign_in_attempt` event" do
        expect { sign_in_jobseeker(email: email, password: password) }
          .to have_triggered_event(:jobseeker_sign_in_attempt)
          .with_data(expected_data)
      end
    end
  end

  context "when entering incorrect details followed by correct detail" do
    let(:email) { jobseeker.email }
    let(:password) { "incorrect_password" }

    it "does not sign in the jobseeker, displays error messages, then signs in the jobseeker" do
      sign_in_jobseeker(email: email, password: password)
      sign_in_jobseeker(email: email, password: jobseeker.password)
      expect(current_path).to eq(jobseeker_root_path)
      expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
    end
  end
end
