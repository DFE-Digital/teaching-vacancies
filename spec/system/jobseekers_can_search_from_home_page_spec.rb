require "rails_helper"

RSpec.describe "Searching on the home page", vcr: { cassette_name: "algoliasearch" } do
  let!(:bristol) { create(:location_polygon, name: "bristol") }

  before do
    visit root_path
  end

  it "defaults to a radius of 10 miles" do
    expect(page.find("#radius-field").value).to eq("10")
  end

  it "persists search terms to the jobs index page" do
    fill_in "Keyword", with: "math"
    fill_in "Location", with: "bristol"
    select "25 miles", from: "radius"

    click_on I18n.t("buttons.search")

    expect(current_path).to eq(jobs_path)
    expect(page.find("#keyword-field").value).to eq("math")
    expect(page.find("#location-field").value).to eq("bristol")
    expect(page.find("#radius-field").value).to eq("25")
  end
end
