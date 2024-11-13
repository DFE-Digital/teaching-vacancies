require "rails_helper"

RSpec.describe "ATS API clients supportal section" do
  before do
    OmniAuth.config.test_mode = true

    stub_support_user_authentication_step
    stub_support_user_authorisation_step

    sign_in_support_user(navigate: true)
  end

  after do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  scenario "support users can list and see the API clients information through the Supportal" do
    old_api_key = SecureRandom.hex(20)
    api_client = create(:publisher_ats_api_client, name: "Test API Client", api_key: old_api_key)
    api_client_name = api_client.name

    click_on "View ATS API clients"
    expect(page).to have_css("h1", text: "ATS API clients")

    click_on "Add new API client"
    expect(page).to have_css("h1", text: "New ATS API Client")

    fill_in "Name", with: "New API Client"
    click_on "Create ATS API Client"
    expect(page).to have_content("ATS API client created successfully")

    click_on "Return to Teaching Vacancies"
    click_on "Support dashboard"
    click_on "View ATS API clients"
    click_on api_client_name
    expect(page).to have_css("h1", text: api_client_name)
    click_on "Rotate ATS API key"

    expect(page).to have_content("API key rotated successfully")
    expect(api_client.reload.api_key).not_to eq(old_api_key)
  end
end
