require "rails_helper"

RSpec.describe "Jobseekers can follow suggestions when a search has no results" do
  before do
    YAML.unsafe_load_file(Rails.root.join("spec/fixtures/polygons.yml")).map(&:attributes).each { |s| LocationPolygon.create!(s) }
    YAML.unsafe_load_file(Rails.root.join("spec/fixtures/liverpool_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
    YAML.unsafe_load_file(Rails.root.join("spec/fixtures/basildon_schools.yml")).map(&:attributes).each { |s| School.create!(s) }

    create(:vacancy, :past_publish, job_title: "Geography teacher", working_patterns: %w[part_time],
                                    organisations: [School.find_by!(town: "Liverpool")])
    create(:vacancy, :past_publish, job_title: "Geography teacher", working_patterns: %w[full_time],
                                    organisations: [School.find_by!(town: "Basildon")])
  end

  scenario "following the suggestion to widen the search area" do
    visit jobs_path(keyword: "geography", location: "liverpool", radius: "5", working_patterns: %w[full_time])

    expect(page).to have_text(I18n.t("vacancies.no_results_suggestions.heading"))
    click_on I18n.t("vacancies.no_results_suggestions.radius", radius: 200)

    expect(page).to have_css("h1", text: I18n.t("jobs.search_result_heading", count: 1))
    expect(page).to have_text("Geography teacher")
    expect(page).to have_field("location-field", with: "liverpool")
  end

  scenario "following the suggestion to remove a filter" do
    visit jobs_path(keyword: "geography", location: "liverpool", radius: "5", working_patterns: %w[full_time])

    click_on I18n.t("vacancies.no_results_suggestions.filter.working_patterns")

    expect(page).to have_css("h1", text: I18n.t("jobs.search_result_heading", count: 1))
  end

  scenario "following the suggestion to correct a misspelt keyword" do
    visit jobs_path(keyword: "geografy")

    click_on "geography"

    expect(page).to have_css("h1", text: I18n.t("jobs.search_result_heading", count: 2))
  end

  scenario "browsing when there is nothing to relax" do
    visit jobs_path(keyword: "unicorn")

    click_on I18n.t("vacancies.no_results_suggestions.browse.teaching")

    expect(page).to have_css("h1", text: I18n.t("jobs.search_result_heading", count: 2))
  end
end
