require "rails_helper"

RSpec.describe "Publishers can preview a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }
  let(:vacancy) { create(:vacancy, :draft, :teacher, :ect_suitable, organisations: [school], phases: %w[secondary], key_stages: %w[ks1]) }

  before { login_publisher(publisher: publisher, organisation: school) }

  context "when reviewing a draft vacancy" do
    before { visit organisation_job_review_path(vacancy.id) }

    scenario "review page shows preview, submit and save calls to action" do
      expect(page).to have_selector(:link_or_button, I18n.t("buttons.preview_job_listing"))
      expect(page).to have_selector(:link_or_button, I18n.t("buttons.submit_job_listing"))
      expect(page).to have_selector(:link_or_button, I18n.t("buttons.back_to_manage_jobs"))
    end

    scenario "users can preview the listing" do
      click_on I18n.t("buttons.preview_job_listing")
      expect(page).to have_current_path(organisation_job_preview_path(vacancy.id, back_to: "review"))
      within(".govuk-info-summary__title") do
        expect(page).to have_content(vacancy.job_title)
      end
    end

    scenario "users can submit the listing" do
      click_on I18n.t("buttons.submit_job_listing")
      expect(page).to have_current_path(organisation_job_summary_path(vacancy.id))
      expect(page).to have_content(I18n.t("publishers.vacancies.summary.heading.published"))
    end

    scenario "users can navigate back to manage jobs page" do
      click_on I18n.t("buttons.back_to_manage_jobs")
      expect(page).to have_current_path(jobs_with_type_organisation_path("draft", from_review: vacancy.id))
    end
  end

  context "when previewing a vacancy" do
    before { visit organisation_job_preview_path(vacancy.id) }

    scenario "users can make changes to the listing" do
      click_on I18n.t("buttons.make_changes")
      expect(page).to have_current_path(organisation_job_review_path(vacancy.id))
    end

    scenario "users can submit the listing" do
      click_on I18n.t("buttons.submit_for_publication")
      expect(page).to have_current_path(organisation_job_summary_path(vacancy.id))
    end
  end
end
