require "rails_helper"

RSpec.describe "Hiring staff can only see their school" do
  context "when the session is connected to a school" do
    scenario "school page can be viewed" do
      school = create(:school)
      stub_hiring_staff_auth(urn: school.urn)

      visit organisation_path

      expect(page).to have_content(school.name)
    end
  end

  context "when the session is NOT connected to a known school" do
    scenario "returns a 404" do
      create(:school)
      stub_hiring_staff_auth(urn: "foo")

      visit organisation_path

      expect(page).to have_content("Page not found")
    end
  end
end
