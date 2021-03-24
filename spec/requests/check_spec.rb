require "rails_helper"

RSpec.describe "Check endpoint" do
  it "returns a 404 for html" do
    get "/check"

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include("application/json")
    expect(response.body).to include("OK")
  end
end
