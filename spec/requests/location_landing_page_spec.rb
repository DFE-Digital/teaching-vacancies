require "rails_helper"

RSpec.describe "Location landing pages" do
  describe "GET #index" do
    before { create(:location_polygon, name: "stoke-on-trent") }

    it "can find location polygons which have non-letter characters in their name" do
      get "/teaching-jobs-in-stoke-on-trent"
      expect(response).to have_http_status(:ok)
    end
  end
end
