require "rails_helper"

RSpec.describe "Searching on the home page" do
  let!(:bristol) { create(:location_polygon, name: "bristol") }

  before do
    visit root_path
  end

  it "persists search terms to the jobs index page" do
    fill_in I18n.t("jobs.search.keyword"), with: "math"
    fill_in I18n.t("home.search.location_label"), with: "bristol"

    click_on I18n.t("buttons.search")

    expect(page).to have_current_path(jobs_path, ignore_query: true)
    expect(page.find_by_id("keyword-field").value).to eq("math")
    expect(page.find_by_id("keyword-field").value).to eq("math")
    expect(page.find_by_id("location-field").value).to eq("bristol")
    expect(page.find_by_id("location-field").value).to eq("bristol")
  end

  context "when the location is not a polygon" do
    it "resets radius to a default radius" do
      fill_in I18n.t("jobs.search.keyword"), with: "math"
      fill_in I18n.t("home.search.location_label"), with: "my house"

      click_on I18n.t("buttons.search")

      expect(page).to have_current_path(jobs_path, ignore_query: true)
      expect(page.find_by_id("keyword-field").value).to eq("math")
      expect(page.find_by_id("keyword-field").value).to eq("math")
      expect(page.find_by_id("location-field").value).to eq("my house")
      expect(page.find_by_id("location-field").value).to eq("my house")
      expect(page.find_by_id("radius-field").value).to eq(Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES.to_s)
      expect(page.find_by_id("radius-field").value).to eq(Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES.to_s)
    end
  end
end
