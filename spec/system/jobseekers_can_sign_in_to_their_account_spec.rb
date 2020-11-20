require "rails_helper"

RSpec.describe "Jobseekers can sign in to their account" do
  let!(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com", password: "correct_horse_battery_staple") }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
  end

  scenario "signing in takes them to saved jobs page with banner" do
    # TODO: Implement me properly when signing in is implemented
    visit new_jobseeker_session_path

    fill_in "Email", with: "jobseeker@example.com"
    fill_in "Password", with: "correct_horse_battery_staple"
    click_button "Log in"

    expect(current_path).to eq(jobseekers_saved_jobs_path)
    expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
  end
end
