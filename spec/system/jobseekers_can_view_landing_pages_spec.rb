require "rails_helper"

RSpec.describe "Jobseekers can view landing pages" do
  let(:school) { create(:school) }
  let!(:vacancy) { create(:vacancy, job_title: "Head of Hogwarts", subjects: %w[Potions], working_patterns: %w[part_time], organisations: [school]) }

  it "contains the expected content and vacancies" do
    visit landing_page_path("part-time-potions-and-sorcery-teacher-jobs")

    expect(page.title).to eq("Spiffy Part Time Potions and Sorcery Jobs - Teaching Vacancies")

    expect(page).to have_css("h1", text: "1 amazing jobs APPLY NOW")
    expect(page).to have_link("Head of Hogwarts")
  end
end
