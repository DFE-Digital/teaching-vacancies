require "rails_helper"

RSpec.describe "API clients supportal section" do
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
    api_client = create(:api_client, name: "Test API Client", api_key: old_api_key)
    api_client_name = api_client.name

    click_on "View API clients"
    expect(page).to have_css("h1", text: "API clients")

    click_on api_client_name
    expect(page).to have_css("h1", text: api_client_name)
    click_on "Rotate API key"

    expect(page).to have_content("API key rotated successfully")
    expect(api_client.reload.api_key).not_to eq(old_api_key)
  end
end
