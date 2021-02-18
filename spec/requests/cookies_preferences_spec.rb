require "rails_helper"

RSpec.describe "CookiesPreferences", type: :request do
  describe "GET #new" do
    it "returns success" do
      get cookies_preferences_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "sets cookie value" do
      post create_cookies_preferences_path, params: { cookies_consent: "yes" }
      expect(response.cookies["consented-to-cookies"]).to eq("yes")
    end
  end
end
