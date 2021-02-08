require "rails_helper"

RSpec.describe "Jobseekers can sign in to their account" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    visit root_path
    within("nav") do
      click_on I18n.t("buttons.sign_in")
    end
    sign_in_jobseeker(email: email, password: password)
  end

  context "when entering correct details" do
    let(:email) { jobseeker.email }
    let(:password) { jobseeker.password }

    it "signs in the jobseeker" do
      expect(current_path).to eq(jobseekers_saved_jobs_path)
      expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
    end
  end

  context "when entering incorrect details" do
    context "when details are missing" do
      let(:email) { "" }
      let(:password) { "" }

      it "does not sign in the jobseeker and displays an error message" do
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).not_to have_selector(".govuk-notification")
        expect(page).to have_content(I18n.t("activerecord.errors.models.jobseeker.attributes.email.blank"))
        expect(page).to have_content(I18n.t("activerecord.errors.models.jobseeker.attributes.password.blank"))
      end
    end

    context "when the account does not exist" do
      let(:email) { "fake@email.com" }
      let(:password) { jobseeker.password }

      it "does not sign in the jobseeker and displays a general error message" do
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).not_to have_selector(".govuk-notification")
        expect(page).to have_content(I18n.t("devise.failure.invalid"))
      end
    end

    context "when the password is incorrect" do
      let(:email) { jobseeker.email }
      let(:password) { "incorrect_password" }

      it "does not sign in the jobseeker and displays a general error message" do
        expect(current_path).to eq(jobseeker_session_path)
        expect(page).not_to have_selector(".govuk-notification")
        expect(page).to have_content(I18n.t("devise.failure.invalid"))
      end
    end
  end

  context "when entering incorrect details followed by correct detail" do
    let(:email) { jobseeker.email }
    let(:password) { "incorrect_password" }

    it "does not sign in the jobseeker, displays error messages, then signs in the jobseeker" do
      sign_in_jobseeker(email: email, password: jobseeker.password)
      expect(current_path).to eq(jobseekers_saved_jobs_path)
      expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
    end
  end
end
