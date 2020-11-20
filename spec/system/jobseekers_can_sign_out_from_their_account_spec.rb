require "rails_helper"

RSpec.describe "Jobseekers can sign out from their account" do
  let!(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com") }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  scenario "signing out takes them to sign in page with banner" do
    # TODO: Implement me properly when we have a real "sign out" link in the header
    visit jobseekers_account_path
    click_button "Temporary log out button until we create a proper logout link in the header"

    expect(current_path).to eq(new_jobseeker_session_path)
    expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
  end
end
