require "rails_helper"

RSpec.describe "Colleges" do
  describe "GET /colleges" do
    it "renders successfully and excludes trust organisations" do
      college = create(:college, name: "Test College")
      trust = create(:trust, name: "Test Trust")

      get colleges_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(college.name)
      expect(response.body).not_to include(trust.name)
    end
  end
end
