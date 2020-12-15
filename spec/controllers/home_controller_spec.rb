require "rails_helper"

RSpec.describe HomeController, type: :controller do
  describe "#index" do
    it "should have an index robots header" do
      get :index
      expect(response.headers["X-Robots-Tag"]).to include("index")
    end
  end
end
