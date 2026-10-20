require "rails_helper"

RSpec.describe "keyword location landing pages" do
  describe "GET #index" do
    it "returns 200 for a valid, targeted keyword and location combo" do
      get "/headteacher-jobs/birmingham"
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for non targetted keywords" do
      get "/nonsense-jobs/nottingham"
      expect(response).to have_http_status(:not_found)
    end
  end
end
