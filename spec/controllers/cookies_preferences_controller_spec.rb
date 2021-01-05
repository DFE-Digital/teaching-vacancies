require "rails_helper"

RSpec.describe CookiesPreferencesController, type: :controller do
  describe "#new" do
    it "returns success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "#create" do
    it "sets cookie value" do
      post :create, params: { cookies_consent: "yes" }
      expect(response.cookies["consented-to-cookies"]).to eq("yes")
    end
  end
end
