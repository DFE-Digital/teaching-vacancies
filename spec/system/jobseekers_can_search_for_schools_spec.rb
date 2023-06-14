require "rails_helper"

RSpec.describe "Searching on the schools page" do
  let(:secondary_school) { create(:school, name: "Oxford") }
  let(:secondary_special_school) { create(:school, name: "Cambridge", gias_data: { "SpecialClasses (code)" => "1" }) }
  let(:primary_school) { create(:school, name: "St Peters", phase: "primary") }

  before do
    create(:publisher, organisations: [secondary_school])
    create(:publisher, organisations: [secondary_special_school])
    create(:publisher, organisations: [primary_school])
    create(:vacancy, organisations: [secondary_school])
    create(:vacancy, organisations: [secondary_special_school])
    create(:vacancy, organisations: [primary_school])
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
      expect(page).to have_link secondary_special_school.name
      expect(page).to have_link secondary_school.name
      expect(page).to have_link primary_school.name

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

      expect(page).to have_link secondary_special_school.name
      expect(page).to have_link secondary_school.name
      expect(page).to have_link primary_school.name

      expect(page).not_to have_link(I18n.t("organisations.search.results.phases.secondary"))
      expect(page).not_to have_link(I18n.t("organisations.filters.special_school"))
    end
  end
end
