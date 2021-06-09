require "rails_helper"

RSpec.describe "Searching on the home page", vcr: { cassette_name: "algoliasearch" } do
  before do
    visit root_path

    fill_in "Keyword", with: "math"
    fill_in "Enter a location", with: "bristol"

    page.find(".govuk-details").click

    check "Suitable for NQTs"
    check "Primary"
    check "Full-time"
    check "Part-time"

    click_on I18n.t("buttons.search")
  end

  it "persists search terms and filter selections to the jobs index page" do
    expect(current_path).to eq(jobs_path)

    expect(page.find("#keyword-field").value).to eq("math")
    expect(page.find("#location-field").value).to eq("bristol")

    expect(page).to have_css(".filters-component__remove-tags__tag", count: 4)

    expect(page.find("#job-roles-nqt-suitable-field")).to be_checked
    expect(page.find("#phases-primary-field")).to be_checked
    expect(page.find("#working-patterns-part-time-field")).to be_checked
    expect(page.find("#working-patterns-full-time-field")).to be_checked
  end
end
