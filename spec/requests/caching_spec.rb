require "rails_helper"

RSpec.describe "Caching", type: :request do
  describe "vacancies#index" do
    it "sets the cache-control to 5 minutes" do
      get jobs_path
      expect(response.headers["cache-control"]).to eq("max-age=300, public")
    end
  end

  describe "vacancies#show" do
    it "sets the cache-control to 5 minutes" do
      vacancy = create(:vacancy)

      get jobs_path(vacancy.id)

      expect(response.headers["cache-control"]).to eq("max-age=300, public")
    end
  end

  describe "stats#index" do
    it "sets the cache-control to 60 minutes" do
      get stats_path

      expect(response.headers["cache-control"]).to eq("max-age=3600, public")
    end
  end
end
