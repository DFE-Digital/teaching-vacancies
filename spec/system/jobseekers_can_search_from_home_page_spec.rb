require "rails_helper"

RSpec.describe "Searching on the home page", vcr: { cassette_name: "algoliasearch" } do
  let!(:bristol) { create(:location_polygon, name: "bristol") }

  before do
    visit root_path
  end

  scenario "defaults to a radius of 0 miles" do
    expect(page.find("#radius-field").value).to eq("0")
  end

  scenario "persists search terms to the jobs index page" do
    fill_in "Keyword", with: "math"
    fill_in "Location", with: "bristol"
    select "25 miles", from: "radius"

    click_on I18n.t("buttons.search")

    expect(current_path).to eq(jobs_path)
    expect(page.find("#keyword-field").value).to eq("math")
    expect(page.find("#location-field").value).to eq("bristol")
    expect(page.find("#radius-field").value).to eq("25")
  end

  context "when the location is not a polygon and the radius is 0" do
    scenario "resets radius to a default radius" do
      fill_in "Keyword", with: "math"
      fill_in "Location", with: "my house"
      select I18n.t("jobs.search.number_of_miles", count: 0), from: "radius"

      click_on I18n.t("buttons.search")

      expect(current_path).to eq(jobs_path)
      expect(page.find("#keyword-field").value).to eq("math")
      expect(page.find("#location-field").value).to eq("my house")
      expect(page.find("#radius-field").value).to eq(Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES.to_s)
    end
  end
end
