require "rails_helper"

RSpec.describe "Searching on the home page", vcr: { cassette_name: "algoliasearch" } do
  let(:home_page) { PageObjects::Home.new }
  let(:jobs_page) { PageObjects::Vacancy::Index.new }

  before do
    home_page.load

    home_page.filters.keyword.set "math"
    home_page.filters.location.set "bristol"

    home_page.filters.toggle_visibility

    home_page.filters.nqt_suitable.check
    home_page.filters.primary.check
    home_page.filters.part_time.check
    home_page.filters.full_time.check

    home_page.search
  end

  it "persists search terms and filter selections to the jobs index page" do
    expect(jobs_page).to be_displayed

    expect(jobs_page.filters.keyword.value).to eq "math"
    expect(jobs_page.filters.location.value).to eq "bristol"

    expect(jobs_page.filters.selected).to have_tags(count: 4)

    expect(jobs_page.filters.nqt_suitable).to be_checked
    expect(jobs_page.filters.primary).to be_checked
    expect(jobs_page.filters.part_time).to be_checked
    expect(jobs_page.filters.full_time).to be_checked
  end
end
