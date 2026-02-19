require "rails_helper"

RSpec.describe "Support users can manage API clients" do
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

  describe "Managing API clients" do
    before do
      visit support_users_publisher_ats_api_clients_path
    end

    context "with an API client" do
      let(:api_client_name) { "Test API Client" }
      let(:old_api_key) { SecureRandom.hex(20) }
      let!(:api_client) { create(:publisher_ats_api_client, name: api_client_name, api_key: old_api_key) }

      before do
        visit current_path
      end

      it "can rotate the API key" do
        click_on api_client_name
        expect(page).to have_css("h1", text: api_client_name)
        click_on "Rotate ATS API key"

        expect(page).to have_content("API key rotated successfully")
        expect(api_client.reload.api_key).not_to eq(old_api_key)
      end

      it "can view conflict attempts" do
        vacancy = create(:vacancy, job_title: "Test Job")
        create(:vacancy_conflict_attempt,
               publisher_ats_api_client: api_client,
               conflicting_vacancy: vacancy,
               attempts_count: 3,
               first_attempted_at: 2.days.ago,
               last_attempted_at: 1.day.ago)

        click_on api_client_name
        expect(page).to have_css("h1", text: api_client_name)
        click_on "View conflict attempts"

        expect(page).to have_css("h1", text: "#{api_client_name} - Conflict Attempts")
        expect(page).to have_content("Test Job")
        expect(page).to have_content("3")
      end
    end

    it "can add an API client" do
      expect(page).to have_css("h1", text: "ATS API clients")

      click_on "Add new API client"
      expect(page).to have_css("h1", text: "New ATS API Client")

      fill_in "Name", with: "New API Client"
      click_on "Create ATS API Client"
      expect(page).to have_content("ATS API client created successfully")

      click_on "Return to Teaching Vacancies"
      click_on "Support dashboard"
    end
  end
end
