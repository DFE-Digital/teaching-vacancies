require "rails_helper"

RSpec.describe "Jobseekers can sign out from their account" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  scenario "signing out takes them to sign in page with banner" do
    visit root_path
    within(".govuk-header__navigation") do
      expect(page).to have_link(I18n.t("nav.sign_out"),
                                href: /^#{Jobseekers::GovukOneLogin::ENDPOINTS[:logout]}.*post_logout_redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fjobseekers%2Fsign_out/)
    end

    one_login_logout_url = find("a", text: I18n.t("nav.sign_out"))[:href]

    stub_request(:get, Jobseekers::GovukOneLogin::ENDPOINTS[:logout])
      .with(query: hash_including({}))
      .to_return(status: 301, headers: { "Location" => "http://localhost:3000/jobseekers/sign_out&state=e333acc9-652d-4cc1-9893-7841e31cb7a5" })

    # The rack_test driver doesn't support requests to external urls (the domain info is just ignored and all paths are
    # routed directly to the AUT)
    # https://stackoverflow.com/questions/49171142/rspec-capybara-redirect-to-external-page-sends-me-back-to-root-path
    # Simulates the external request directly
    Net::HTTP.get(URI(one_login_logout_url))
    expect(a_request(:get, Jobseekers::GovukOneLogin::ENDPOINTS[:logout]).with(query: hash_including({}))).to have_been_made.once
    # Simulate the callback response from GovUK One Login
    visit jobseekers_sign_out_path

    expect(current_path).to eq(new_jobseeker_session_path)
    expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
  end
end
