require "rails_helper"

RSpec.describe "Caching", type: :request do
  describe "stats#index" do
    it "sets the cache-control to 60 minutes" do
      get stats_path

      expect(response.headers["cache-control"]).to eq("max-age=3600, public")
    end
  end
end
