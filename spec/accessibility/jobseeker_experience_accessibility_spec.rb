require "rails_helper"

RSpec.describe "Jobseeker experience accessibility", type: :system, accessibility: true do
  let(:school) { create(:school) }
  let!(:job1) { create(:vacancy, :past_publish, job_title: "Teacher of Potions", organisation_vacancies_attributes: [{ organisation: school }]) }

  scenario "jobseeker visits homepage, performs a search, and views a job page" do
    visit root_path
    expect(page).to meet_accessibility_standards

    click_on "Search"
    expect(page).to meet_accessibility_standards

    click_on "Teacher of Potions"
    expect(page).to meet_accessibility_standards
  end
end
