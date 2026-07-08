require "rails_helper"

RSpec.describe "Organisations" do
  describe "GET /schools/:id" do
    it "renders successfully for a school" do
      school = create(:school)
      get organisation_path(school)
      expect(response).to have_http_status(:ok)
    end

    it "renders successfully for a college" do
      college = create(:college)
      get organisation_path(college)
      expect(response).to have_http_status(:ok)
    end

    it "returns not found for a soft-deleted organisation" do
      school = create(:school)
      school.discard
      get organisation_path(school)
      expect(response).to have_http_status(:not_found)
    end
  end
end
