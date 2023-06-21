require "rails_helper"

RSpec.describe "CookiesPreferences" do
  describe "GET #new" do
    it "returns success" do
      get cookies_preferences_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "sets cookie values" do
      post create_cookies_preferences_path, params: { cookies_analytics_consent: "yes",
                                                      cookies_marketing_consent: "no" }
      expect(response.cookies["consented-to-analytics-cookies"]).to eq("yes")
      expect(response.cookies["consented-to-marketing-cookies"]).to eq("no")
    end
  end
end
