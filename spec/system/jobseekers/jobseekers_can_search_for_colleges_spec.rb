require "rails_helper"

RSpec.describe "Searching on the colleges page" do
  let(:secondary_school) { create(:college, name: "Oxford", phase: "secondary") }
  let(:primary_school) { create(:college, name: "St Peters", phase: "primary") }
  let(:special_school1) { create(:college, name: "Community special school", phase: "secondary", detailed_school_type: "Community special school") }

  let!(:no_vacancies) do
    create(:college, name: "No Vacancies").tap do |nv|
      create(:publisher, organisations: [nv])
    end
  end

  before do
    [secondary_school, primary_school, special_school1].each do |school|
      create(:publisher, organisations: [school])
      create(:vacancy, organisations: [school])
    end
    visit colleges_path
  end

  context "when filtering by vacancies" do
    it "allows filtering by schools with vacancies" do
      expect(page).to have_link no_vacancies.name
      check I18n.t("organisations.filters.college_job_availability.options.true")

      # Apply filters
      within ".govuk-grid-column-one-third-at-desktop" do
        first("button").click
      end
      expect(page).to have_no_link no_vacancies.name
    end
  end

  def expect_page_to_show_schools(schools)
    schools.each do |school|
      expect(page).to have_link school.name
    end
  end

  def expect_page_not_to_show_schools(schools)
    schools.each do |school|
      expect(page).to have_no_link school.name
    end
  end
end
