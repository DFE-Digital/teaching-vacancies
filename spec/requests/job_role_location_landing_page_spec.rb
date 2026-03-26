require "rails_helper"

RSpec.describe "Job role + location landing pages" do
  describe "GET #index" do
    it "returns 200 for a valid, targeted job role and location combo" do
      get "/teaching-assistant-jobs-in-london"
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for a valid job role not in the targeted list" do
      get "/teacher-jobs-in-london"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a valid location not in the targeted list" do
      get "/teaching-assistant-jobs-in-leeds"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a invalid combo" do
      get "/footballer-jobs-in-birmingham"
      expect(response).to have_http_status(:not_found)
    end
  end
end
