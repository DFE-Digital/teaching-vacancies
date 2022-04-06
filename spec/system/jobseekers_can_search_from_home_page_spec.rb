require "rails_helper"

RSpec.describe "Searching on the home page" do
  let!(:bristol) { create(:location_polygon, name: "bristol") }

  before do
    visit root_path
  end

  scenario "persists search terms to the jobs index page" do
    fill_in I18n.t("jobs.search.keyword"), with: "math"
    fill_in I18n.t("home.search.location_label"), with: "bristol"

    click_on I18n.t("buttons.search")

    expect(current_path).to eq(jobs_path)
    expect(page.find(".search-and-filters-form").find("#keyword-field").value).to eq("math")
    expect(page.find(".search-and-filters-form").find("#keyword-field").value).to eq("math")
    expect(page.find(".search-and-filters-form").find("#location-field").value).to eq("bristol")
    expect(page.find(".search-and-filters-form").find("#location-field").value).to eq("bristol")
  end

  context "when the location is not a polygon" do
    scenario "resets radius to a default radius" do
      fill_in I18n.t("jobs.search.keyword"), with: "math"
      fill_in I18n.t("home.search.location_label"), with: "my house"

      click_on I18n.t("buttons.search")

      expect(current_path).to eq(jobs_path)
      expect(page.find(".search-and-filters-form").find("#keyword-field").value).to eq("math")
      expect(page.find(".search-and-filters-form").find("#keyword-field").value).to eq("math")
      expect(page.find(".search-and-filters-form").find("#location-field").value).to eq("my house")
      expect(page.find(".search-and-filters-form").find("#location-field").value).to eq("my house")
      expect(page.find(".search-and-filters-form").find("#radius-field").value).to eq(Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES.to_s)
      expect(page.find(".search-and-filters-form").find("#radius-field").value).to eq(Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES.to_s)
    end
  end
end
