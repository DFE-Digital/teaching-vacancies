require "rails_helper"

RSpec.describe "Jobseekers can sign out from their account" do
  let!(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com") }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  scenario "signing out takes them to sign in page with banner" do
    visit root_path
    within(".navbar-component") do
      click_on I18n.t("nav.sign_out")
    end

    expect(current_path).to eq(new_jobseeker_session_path)
    expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
  end
end
