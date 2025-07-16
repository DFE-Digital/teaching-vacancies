require "rails_helper"

RSpec.describe "View Component Previews" do
  describe "GET /previews" do
    it "returns http success for index" do
      get "/components"
      expect(response).to have_http_status(:success)
    end
  end
end
