require "rails_helper"

RSpec.describe "Hiring staff can view a public vacancy" do
  scenario "A vacancy page view is not tracked" do
    school = create(:school)
    vacancy = create(:vacancy, :published)
    vacancy.organisation_vacancies.create(organisation: school)
    stub_publishers_auth(urn: school.urn)

    expect { visit job_path(vacancy) }.not_to have_enqueued_job(PersistVacancyPageViewJob)
  end
end
