require "rails_helper"

RSpec.describe "Jobseekers can apply for a vacancy" do
  let(:school) { create(:school) }

  scenario "the application link is without protocol" do
    vacancy = create(:vacancy, :published, application_link: "www.google.com")
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)

    expect(page).to have_link(I18n.t("jobs.apply", href: "http://www.google.com"))
  end

  scenario "it increments the get_more_info_counter in the background" do
    vacancy = create(:vacancy, :published)
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)

    expect { click_on I18n.t("jobs.apply") }.to have_enqueued_job(PersistVacancyGetMoreInfoClickJob).with(vacancy.id)
  end
end
