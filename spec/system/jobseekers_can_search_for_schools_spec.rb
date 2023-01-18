require "rails_helper"

RSpec.describe "Searching on the schools page" do
  before do
    visit organisations_path
  end

  context "when the location is not a polygon" do
    scenario "resets radius to a default radius" do
      fill_in I18n.t("home.search.location_label"), with: "my house"

      click_on I18n.t("buttons.search")

      expect(page.find("#location-field").value).to eq("my house")
      expect(page.find("#location-field").value).to eq("my house")
      expect(page.find("#radius-field").value).to eq(Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES.to_s)
      expect(page.find("#radius-field").value).to eq(Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES.to_s)
    end
  end
end
