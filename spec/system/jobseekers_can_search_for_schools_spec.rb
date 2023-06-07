require "rails_helper"

RSpec.describe "Searching on the schools page" do
  let(:secondary_school) { create(:school, name: "Oxford") }
  let(:secondary_special_school) { create(:school, name: "Cambridge", gias_data: { "SpecialClasses (code)" => "1" }) }
  let(:primary_school) { create(:school, name: "St Peters", phase: "primary") }

  let(:academy_school1) { create(:school, name: "Academy1", gias_data: { "EstablishmentTypeGroup (name)" => "Academies" }) }
  let(:academy_school2) { create(:school, name: "Academy2", gias_data: { "EstablishmentTypeGroup (code)" => "10" }) }
  let(:free_school1) { create(:school, name: "Free school 1", gias_data: { "EstablishmentTypeGroup (name)" => "Free schools" }) }
  let(:free_school2) { create(:school, name: "Free school 1", gias_data: { "EstablishmentTypeGroup (code)" => "11" }) }
  let(:local_authority_school1) { create(:school, name: "Local authority school 1", gias_data: { "EstablishmentTypeGroup (name)" => "Local authority maintained schools" }) }
  let(:local_authority_school2) { create(:school, name: "Local authority school 2", gias_data: { "EstablishmentTypeGroup (code)" => "4" }) }

  before do
    [secondary_school, secondary_special_school, primary_school, academy_school1, academy_school2, free_school1, free_school2, local_authority_school1, local_authority_school2].each do |school|
      create(:publisher, organisations: [school])
      create(:vacancy, organisations: [school])
    end
    visit organisations_path
  end

  context "when the location is not a polygon" do
    scenario "resets radius to a default radius" do
      fill_in I18n.t("home.search.location_label"), with: "my house"

      click_on I18n.t("buttons.search")

      expect(page.find("#location-field").value).to eq("my house")
      expect(page.find("#location-field").value).to eq("my house")
      expect(page.find("#radius-field").value).to eq(Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES.to_s)
      expect(page.find("#radius-field").value).to eq(Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES.to_s)
    end
  end

  context "when filters are selected" do
    before do
      expect_page_to_show_schools([secondary_special_school, secondary_school, primary_school])

      check I18n.t("organisations.search.results.phases.secondary")
      check I18n.t("organisations.filters.special_school")

      click_on I18n.t("buttons.search")

      expect(page).to have_link secondary_special_school.name
      expect(page).not_to have_link secondary_school.name
      expect(page).not_to have_link primary_school.name

      expect(page).to have_link(I18n.t("organisations.search.results.phases.secondary"))
      expect(page).to have_link(I18n.t("organisations.filters.special_school"))
    end

    it "allows jobseeker to clear a filter" do
      click_link I18n.t("organisations.filters.special_school")

      expect(page).to have_link secondary_special_school.name
      expect(page).to have_link secondary_school.name
      expect(page).not_to have_link primary_school.name

      expect(page).to have_link(I18n.t("organisations.search.results.phases.secondary"))
      expect(page).not_to have_link(I18n.t("organisations.filters.special_school"))
    end

    it "allows jobseeker to clear all filters" do
      click_link "Clear filters"

      expect_page_to_show_schools([secondary_special_school, secondary_school, primary_school])

      expect(page).not_to have_link(I18n.t("organisations.search.results.phases.secondary"))
      expect(page).not_to have_link(I18n.t("organisations.filters.special_school"))
    end
  end

  context "when filtering by organisation type" do
    it "allows user to filter by academies" do
      check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
      click_on I18n.t("buttons.search")

      expect_page_to_show_schools([academy_school1, academy_school2, free_school1, free_school2])
      expect_page_not_to_show_schools([local_authority_school1, local_authority_school2, secondary_school, secondary_special_school, primary_school])
    end

    it "allows user to filter by local authorities" do
      check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
      click_on I18n.t("buttons.search")

      expect_page_to_show_schools([local_authority_school1, local_authority_school2])
      expect_page_not_to_show_schools([academy_school1, academy_school2, free_school1, free_school2, secondary_school, secondary_special_school, primary_school])
    end

    it "allows user to filter by both academies and local authorities" do
      check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
      check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
      click_on I18n.t("buttons.search")

      expect_page_to_show_schools([local_authority_school1, local_authority_school2, academy_school1, academy_school2, free_school1, free_school2])
      expect_page_not_to_show_schools([secondary_school, secondary_special_school, primary_school])
    end
  end

  def expect_page_to_show_schools(schools)
    schools.each do |school|
      expect(page).to have_link school.name
    end
  end

  def expect_page_not_to_show_schools(schools)
    schools.each do |school|
      expect(page).not_to have_link school.name
    end
  end
end
