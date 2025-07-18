require "rails_helper"

RSpec.describe "Searching on the home page" do
  before do
    visit root_path
  end

  context "when the location is not a polygon" do
    scenario "resets radius to a default radius" do
      fill_in I18n.t("jobs.search.keyword"), with: "math"
      fill_in I18n.t("home.search.location_label"), with: "my house"

      click_on I18n.t("buttons.search")

      expect(current_path).to eq(jobs_path)
      expect_search_terms_to_be_persisted
      expect(page.find("#radius-field").value).to eq(Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES.to_s)
    end
  end

  def expect_search_terms_to_be_persisted
    expect(page.find("#keyword-field").value).to eq("math")
    expect(page.find("#location-field").value).to eq("my house")
  end
end
