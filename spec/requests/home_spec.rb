require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET #index" do
    it "has an index robots header" do
      get root_path
      expect(response.headers["X-Robots-Tag"]).to include("index")
    end
  end
end
