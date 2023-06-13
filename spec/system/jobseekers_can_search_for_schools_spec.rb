require "rails_helper"

RSpec.describe "Searching on the schools page" do
  let(:secondary_school) { create(:school, name: "Oxford") }
  let(:primary_school) { create(:school, name: "St Peters", phase: "primary") }
  let(:special_school1) { create(:school, name: "Community special school", school_type: "Community special school") }


  before do
    [secondary_school, primary_school, special_school1].each do |school|
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
      check I18n.t("organisations.search.results.phases.secondary")
      check I18n.t("organisations.filters.special_school")

      click_on I18n.t("buttons.search")

      expect_page_to_show_schools([special_school1,])
      expect_page_not_to_show_schools([secondary_school, primary_school])

      expect(page).to have_link(I18n.t("organisations.search.results.phases.secondary"))
      expect(page).to have_link(I18n.t("organisations.filters.special_school"))
    end

    it "allows jobseeker to clear a filter" do
      click_link I18n.t("organisations.filters.special_school")

      expect_page_to_show_schools([special_school1, secondary_school])
      expect_page_not_to_show_schools([primary_school])

      expect(page).to have_link(I18n.t("organisations.search.results.phases.secondary"))
      expect(page).not_to have_link(I18n.t("organisations.filters.special_school"))
    end

    it "allows jobseeker to clear all filters" do
      click_link "Clear filters"

      expect_page_to_show_schools([special_school1, secondary_school, primary_school])

      expect(page).not_to have_link(I18n.t("organisations.search.results.phases.secondary"))
      expect(page).not_to have_link(I18n.t("organisations.filters.special_school"))
    end
  end

  context "when filtering by organisation type" do
    let(:academy_school1) { create(:school, name: "Academy1", school_type: "Academies") }
    let(:academy_school2) { create(:school, name: "Academy2", school_type: "Academy") }
    let(:free_school1) { create(:school, name: "Free school 1", school_type: "Free schools") }
    let(:free_school2) { create(:school, name: "Free school 1", school_type: "Free school") }
    let(:local_authority_school) { create(:school, name: "Local authority school 1", school_type: "Local authority maintained schools") }

    before do
      [academy_school1, academy_school2, free_school1, free_school2, local_authority_school].each do |school|
        create(:publisher, organisations: [school])
        create(:vacancy, organisations: [school])
      end
      visit organisations_path
    end

    it "allows user to filter by academies" do
      check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
      click_on I18n.t("buttons.search")

      expect_page_to_show_schools([academy_school1, academy_school2, free_school1, free_school2])
      expect_page_not_to_show_schools([local_authority_school, secondary_school, special_school1, primary_school])
    end

    it "allows user to filter by local authorities" do
      check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
      click_on I18n.t("buttons.search")

      expect_page_to_show_schools([local_authority_school])
      expect_page_not_to_show_schools([academy_school1, academy_school2, free_school1, free_school2, secondary_school, special_school1, primary_school])
    end

    it "allows user to filter by both academies and local authorities" do
      check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
      check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
      click_on I18n.t("buttons.search")

      expect_page_to_show_schools([local_authority_school, academy_school1, academy_school2, free_school1, free_school2])
      expect_page_not_to_show_schools([secondary_school, special_school1, primary_school])
    end
  end

  context "when filtering by school type" do
    let(:faith_school) { create(:school, name: "Religious", gias_data: {"ReligiousCharacter (name)" => "anything"}) }
    let(:special_school2) { create(:school, name: "Foundation special school", school_type: "Foundation special school") }
    let(:special_school3) { create(:school, name: "Non-maintained special school", school_type: "Non-maintained special school") }
    let(:special_school4) { create(:school, name: "Academy special converter", school_type: "Academy special converter") }
    let(:special_school5) { create(:school, name: "Academy special sponsor led", school_type: "Academy special sponsor led") }
    let(:special_school6) { create(:school, name: "Non-maintained special school", school_type: "Free schools special") }

    before do
      [faith_school, special_school2, special_school3, special_school4, special_school5, special_school6].each do |school|
        create(:publisher, organisations: [school])
        create(:vacancy, organisations: [school])
      end
      visit organisations_path
    end

    it "allows user to filter by special schools" do
      check "Special school"
      click_on I18n.t("buttons.search")

      expect_page_to_show_schools([special_school1, special_school2, special_school3, special_school4, special_school5, special_school6])
      expect_page_not_to_show_schools([secondary_school, primary_school, faith_school])
    end

    it "allows users to filter by faith schools" do
      check "Faith school"
      click_on I18n.t("buttons.search")

      expect_page_to_show_schools([faith_school])
      expect_page_not_to_show_schools([secondary_school, primary_school, special_school1, special_school2, special_school3, special_school4, special_school5, special_school6])
    end

    it "allows users to filter by faith schools AND special schools" do
      check "Faith school"
      check "Special school"
      click_on I18n.t("buttons.search")

      expect_page_to_show_schools([faith_school, special_school1, special_school2, special_school3, special_school4, special_school5, special_school6])
      expect_page_not_to_show_schools([secondary_school, primary_school])
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
