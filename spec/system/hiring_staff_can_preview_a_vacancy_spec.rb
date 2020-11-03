require "rails_helper"

RSpec.describe "Hiring staff can preview a vacancy" do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }
  let(:vacancy) { create(:vacancy, :draft) }

  before(:each) do
    vacancy.organisation_vacancies.create(organisation: school)
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  context "when reviewing a draft vacancy" do
    before do
      visit organisation_job_review_path(vacancy.id)
    end

    scenario "review page shows preview, submit and save calls to action" do
      expect(page).to have_content(I18n.t("jobs.preview_listing.button"))
      expect(page).to have_content(I18n.t("jobs.submit_listing.button"))
      expect(page).to have_content(I18n.t("buttons.back_to_manage_jobs"))
    end

    scenario "users can preview the listing" do
      click_on I18n.t("jobs.preview_listing.button")
      expect(page).to have_current_path(organisation_job_preview_path(vacancy.id))
      within(".govuk-info-summary__title") do
        expect(page).to have_content(vacancy.job_title)
      end
    end

    scenario "users can submit the listing" do
      click_on I18n.t("jobs.submit_listing.button")
      expect(page).to have_current_path(organisation_job_summary_path(vacancy.id))
      expect(page).to have_content(I18n.t("jobs.confirmation_page.submitted"))
    end

    scenario "users can navigate back to manage jobs page" do
      click_on I18n.t("buttons.back_to_manage_jobs")
      expect(page).to have_current_path(jobs_with_type_organisation_path("draft", from_review: vacancy.id))
      expect(page).to have_content(I18n.t("schools.jobs.index", organisation: school.name))
      expect(page).to have_content(I18n.t("buttons.create_job"))
    end
  end

  context "when previewing a vacancy" do
    before do
      visit organisation_job_preview_path(vacancy.id)
    end

    scenario "users can make changes to the listing" do
      click_on I18n.t("jobs.preview_listing.summary.buttons.make_changes")
      expect(page).to have_current_path(organisation_job_review_path(vacancy.id))
    end

    scenario "users can submit the listing" do
      click_on I18n.t("jobs.preview_listing.summary.buttons.submit")
      expect(page).to have_current_path(organisation_job_summary_path(vacancy.id))
    end
  end
end
