require "rails_helper"

RSpec.describe "Publishers::Organisations", type: :request do
  describe "sets headers" do
    it "robots are asked not to index or to follow" do
      get jobs_with_type_organisation_path
      expect(response.headers["X-Robots-Tag"]).to eq("noindex, nofollow")
    end
  end
end
