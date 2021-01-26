require "rails_helper"

RSpec.describe "School viewing vacancies" do
  let(:school) { create(:school) }
  before(:each) do
    stub_publishers_auth(urn: school.urn)
  end

  scenario "A school publisher sees advisory text when there are no vacancies" do
    visit organisation_path

    expect(page).to have_content(I18n.t("schools.no_jobs.heading"))
    expect(page).not_to have_css(".vacancies")
    expect(page).to have_content(I18n.t("schools.no_jobs.heading"))
  end

  scenario "A school publisher can see a list of vacancies" do
    vacancy1 = create(:vacancy)
    vacancy1.organisation_vacancies.create(organisation: school)
    vacancy2 = create(:vacancy)
    vacancy2.organisation_vacancies.create(organisation: school)

    visit organisation_path

    expect(page).to have_content(school.name)
    expect(page).to have_content(vacancy1.job_title)
    expect(page).to have_content(vacancy2.job_title)
  end

  scenario "A draft vacancy show page shows a flash message with the status" do
    vacancy = create(:vacancy, status: "draft")
    vacancy.organisation_vacancies.create(organisation: school)

    visit organisation_job_path(vacancy.id)

    expect(page).to have_content(school.name)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(I18n.t("publishers.vacancies.show.notice"))
  end

  scenario "A published vacancy show page does not show a flash message with the status" do
    vacancy = create(:vacancy, status: "published")
    vacancy.organisation_vacancies.create(organisation: school)

    visit organisation_job_path(vacancy.id)

    expect(page).to have_content(school.name)
    expect(page).to have_content(vacancy.job_title)
  end

  scenario "clicking on more information does not increment the counter" do
    vacancy = create(:vacancy, status: "published")
    vacancy.organisation_vacancies.create(organisation: school)

    visit organisation_job_path(vacancy.id)

    expect { click_on I18n.t("jobs.apply") }.to change { vacancy.get_more_info_counter.to_i }.by(0)
  end
end
