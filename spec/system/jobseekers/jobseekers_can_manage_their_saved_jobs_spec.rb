require "rails_helper"

RSpec.describe "Jobseekers manage saved jobs" do
  scenario "lands on saved jobs page: page is accessible, expired job has no apply link, can delete a saved job", :a11y do
    jobseeker = create(:jobseeker)
    school = create(:school)
    active_vacancy = create(:vacancy, enable_job_applications: true, organisations: [school])
    expired_vacancy = create(:vacancy, :expired, organisations: [school])

    jobseeker.saved_jobs.create(vacancy: active_vacancy)
    jobseeker.saved_jobs.create(vacancy: expired_vacancy)

    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_saved_jobs_path

    expect(page).to be_axe_clean
    expect(page).to have_link(I18n.t("jobseekers.saved_jobs.index.apply"))
    expect(page).to have_link(I18n.t("jobseekers.saved_jobs.index.delete"), count: 2)

    within(".card-component", text: expired_vacancy.job_title) do
      expect(page).not_to have_link(I18n.t("jobseekers.saved_jobs.index.apply"))
      click_on I18n.t("jobseekers.saved_jobs.index.delete")
    end

    expect(page).to have_css(".card-component", count: 1)
    expect(page).to have_content(I18n.t("jobseekers.saved_jobs.destroy.success"))
  end
end
