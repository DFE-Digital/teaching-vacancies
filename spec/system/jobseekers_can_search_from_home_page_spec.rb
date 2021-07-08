require "rails_helper"

RSpec.describe "Searching on the home page", vcr: { cassette_name: "algoliasearch" } do
  before do
    visit root_path

    fill_in "Keyword", with: "math"
    fill_in "Location", with: "bristol"

    click_on I18n.t("buttons.search")
  end

  it "persists search terms to the jobs index page" do
    expect(current_path).to eq(jobs_path)

    expect(page.find("#keyword-field").value).to eq("math")
    expect(page.find("#location-field").value).to eq("bristol")
  end
end
