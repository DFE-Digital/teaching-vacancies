require "rails_helper"

RSpec.describe "School viewing vacancies" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  before { login_publisher(publisher:, organisation: school) }

  scenario "A school publisher sees advisory text when there are no vacancies" do
    visit organisation_path

    expect(page).to have_content(I18n.t("publishers.no_vacancies_component.heading"))
    expect(page).not_to have_css(".vacancies")
  end

  scenario "A school publisher can see a list of vacancies" do
    vacancy1 = create(:vacancy, organisations: [school])
    vacancy2 = create(:vacancy, organisations: [school])

    visit organisation_path

    expect(page).to have_content(school.name)
    expect(page).to have_content(vacancy1.job_title)
    expect(page).to have_content(vacancy2.job_title)
  end

  scenario "A published vacancy show page does not show a flash message with the status" do
    vacancy = create(:vacancy, status: "published", organisations: [school])

    visit organisation_job_path(vacancy.id)

    expect(page).to have_content(school.name)
    expect(page).to have_content(vacancy.job_title)
  end
end
