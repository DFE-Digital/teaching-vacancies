require "rails_helper"

RSpec.describe "Publishers can manage job applications for a vacancy" do
  let(:organisation) { create(:school, name: "A school with a vacancy") }
  let(:publisher) { create(:publisher) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_job_job_applications_path(vacancy.id)
  end

  after { logout }

  context "when a vacancy has expired and it has applications", :js do
    let(:vacancy) { create(:vacancy, :expired, expires_at: 2.weeks.ago, organisations: [organisation], job_applications: job_applications) }

    let(:job_applications) do
      [build(:job_application, :status_submitted, last_name: "Alan"),
       build(:job_application, :status_reviewed, last_name: "Charlie"),
       build(:job_application, :status_shortlisted, last_name: "Billy"),
       build(:job_application, :status_unsuccessful, last_name: "Dave"),
       build(:job_application, :status_withdrawn, last_name: "Ethan"),
       build(:job_application, :status_interviewing, last_name: "Freddy"),
       build(:job_application, :status_draft)]
    end
    let(:job_application_submitted) { JobApplication.find_by!(status: "submitted") }
    let(:job_application_reviewed) { JobApplication.find_by!(status: "reviewed") }
    let(:job_application_shortlisted) { JobApplication.find_by!(status: "shortlisted") }
    let(:job_application_unsuccessful) { JobApplication.find_by!(status: "unsuccessful") }
    let(:job_application_withdrawn) {  JobApplication.find_by!(status: "withdrawn") }
    let(:job_application_interviewing) { JobApplication.find_by!(status: "interviewing") }

    scenario "not selecting anything" do
      # Wait for page to fully load
      expect(page).to have_button(I18n.t("publishers.vacancies.job_applications.candidates.update_application_status"), wait: 10)

      click_on I18n.t("publishers.vacancies.job_applications.candidates.update_application_status")
      expect(page).to have_content(I18n.t("activemodel.errors.models.publishers/job_application/tag_form.attributes.job_applications.too_short"), wait: 5)
    end

    scenario "Changing multiple statuses at once" do
      # Wait for page to fully load
      find_by_id("tab_submitted")

      within(".application-reviewed") do
        expect(page).to have_css(".govuk-checkboxes__item", wait: 5)
        find(".govuk-checkboxes__input", visible: false, wait: 5).set(true)
      end

      expect(page).to have_css(".application-submitted", wait: 5)

      within(".application-submitted") do
        expect(page).to have_css(".govuk-checkboxes__item", wait: 5)
        find(".govuk-checkboxes__input", visible: false, wait: 5).set(true)
      end

      # Wait for button to be ready
      expect(page).to have_button(I18n.t("publishers.vacancies.job_applications.candidates.update_application_status"), wait: 5)
      click_on I18n.t("publishers.vacancies.job_applications.candidates.update_application_status")

      # Wait for page transition to complete
      expect(page).to have_css(".govuk-tag--red", wait: 10)
      find(".govuk-tag--red").click
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("Not Considering (3)")
    end

    scenario "Changing a single status" do
      expect(page).to have_button(I18n.t("publishers.vacancies.job_applications.candidates.update_application_status"), wait: 10)
      find_by_id("tab_not_considering", wait: 5).click
      within(".application-unsuccessful") do
        find(".govuk-checkboxes__input", visible: false).set(true)
      end
      click_on I18n.t("publishers.vacancies.job_applications.candidates.update_application_status")
      # wait for page load
      expect(page).to have_css(".govuk-radios", wait: 5)
      choose("Reviewed ")
      # wait for complete render
      within "#main-content" do
        find ".govuk-button"
      end
      click_on "Save and continue"
      expect(page).to have_content("New (3)")
    end
  end
end
