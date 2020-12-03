require "rails_helper"

RSpec.describe "Jobseekers can sign in to their account" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
  end

  scenario "signing in takes them to saved jobs page with banner" do
    visit root_path
    within("nav") do
      click_link I18n.t("buttons.sign_in")
    end

    sign_in_jobseeker

    expect(current_path).to eq(jobseekers_saved_jobs_path)
    expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
  end
end
