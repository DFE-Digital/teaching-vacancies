require "rails_helper"

RSpec.describe "Jobseekers can sign in to their account" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    visit root_path
    within("nav") do
      click_on I18n.t("buttons.sign_in")
    end
  end

  context "with correct credentials" do
    scenario "takes them to the saved jobs page with a banner" do
      sign_in_jobseeker

      expect(current_path).to eq(jobseekers_saved_jobs_path)
      expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
    end
  end

  context "with a email that does not exist" do
    scenario "displays a generic error message" do
      sign_in_jobseeker(email: "i-forgot-my@email-address.com", password: jobseeker.password)

      expect(current_path).to eq(jobseeker_session_path)
      expect(page).to have_content(I18n.t("devise.failure.invalid"))
    end
  end

  context "with incorrect password" do
    scenario "displays a generic error message" do
      sign_in_jobseeker(email: jobseeker.email, password: "wrong and bad")

      expect(current_path).to eq(jobseeker_session_path)
      expect(page).to have_content(I18n.t("devise.failure.invalid"))
    end
  end
end
