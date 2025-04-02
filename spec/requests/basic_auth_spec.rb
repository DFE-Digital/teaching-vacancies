require "rails_helper"

RSpec.describe "HTTP Basic Auth exclusions" do
  let!(:api_client) { create(:publisher_ats_api_client) }

  context "when making a GET request to /ats-api on review app host" do
    it "does not require basic auth" do
      host! "teaching-vacancies-review-pr-1234.test.teacherservices.cloud"
      get "/ats-api/v1/vacancies", headers: {
        "X-Api-Key" => api_client.api_key,
        "Accept" => "application/json",
      }
      expect(response).to have_http_status(:ok)
    end
  end

  context "when making a GET request to homepage without auth on review app host" do
    it "requires basic auth" do
      host! "teaching-vacancies-review-pr-1234.test.teacherservices.cloud"
      get "/"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
