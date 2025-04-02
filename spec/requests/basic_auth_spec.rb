require "rails_helper"

RSpec.describe "HTTP Basic Auth exclusions", type: :request do
  before do
    stub_const("ENV", ENV.to_hash.merge("HTTP_BASIC_PASSWORD" => "secret", "HTTP_BASIC_USER" => "user"))

    Rails.application.routes.draw do
      get "/check" => "application#check"
      get "/ats-api/v1/jobs" => "application#check" # simple action for testing
      get "/ats-api-docs" => "application#check"
      get "/protected" => "application#check"
    end
  end

  context "GET /check" do
    it "does not require basic auth" do
      get "/check"
      expect(response).to have_http_status(:ok)
    end
  end

  context "GET /ats-api on review app host" do
    it "does not require basic auth" do
      host! "teaching-vacancies-review-pr-1234.test.teacherservices.cloud"
      get "/ats-api/v1/jobs"
      expect(response).to have_http_status(:ok)
    end
  end

  context "GET /protected without auth" do
    it "requires basic auth" do
      get "/protected"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "GET /protected with valid credentials" do
    it "allows access" do
      get "/protected", headers: {
        "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("user", "secret")
      }
      expect(response).to have_http_status(:ok)
    end
  end
end
