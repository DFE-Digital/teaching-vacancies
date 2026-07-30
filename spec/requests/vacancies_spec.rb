require "rails_helper"

RSpec.describe "Vacancies" do
  describe "GET #index" do
    it "sets headers robots are asked to index but not to follow" do
      get jobs_path
      expect(response.headers["X-Robots-Tag"]).to eq("noarchive")
    end

    it "clamps to page 1 instead of raising when page is 0" do
      get jobs_path(page: 0)
      expect(response).to have_http_status(:ok)
    end

    it "clamps to page 1 instead of raising when page is negative" do
      get jobs_path(page: -1)
      expect(response).to have_http_status(:ok)
    end
  end
end
