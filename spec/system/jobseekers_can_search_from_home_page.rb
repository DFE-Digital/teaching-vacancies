require "rails_helper"

RSpec.describe "Searching on the home page" do
  before do
    visit root_path
    within ".search_panel" do
      fill_in "keyword", with: "math"
      fill_in "location", with: "bristol"

      # Click 'Add more filters'
      find(".new_ > details").click

      check I18n.t("helpers.label.publishers_job_listing_job_details_form.job_roles_options.nqt_suitable"),
            name: "job_roles[]",
            visible: false
      check I18n.t("jobs.education_phase_options.primary"),
            name: "phases[]",
            visible: false
      check I18n.t("helpers.label.publishers_job_listing_job_details_form.working_patterns_options.part_time"),
            name: "working_patterns[]",
            visible: false
      check I18n.t("helpers.label.publishers_job_listing_job_details_form.working_patterns_options.full_time"),
            name: "working_patterns[]",
            visible: false

      page.find(".govuk-button[type=submit]").click
    end
  end

  scenario "search terms and filter selections are persisted onto the jobs index page" do
    expect(page.current_path).to eq(jobs_path)
    expect(find_field("keywords").value).to eq "math"
    expect(find_field("location").value).to eq "bristol"
    expect(page).to have_css(".moj-filter__tag", count: 3)
    expect(page.find("#job-roles-nqt-suitable-field")).to be_checked
    expect(page.find("#education-phases-primary-field")).to be_checked
    expect(page.find("#education-phases-secondary-field")).not_to be_checked
    expect(page.find("#working-patterns-part-time-field")).to be_checked
    expect(page.find("#working-patterns-full-time-field")).to be_checked
  end
end
