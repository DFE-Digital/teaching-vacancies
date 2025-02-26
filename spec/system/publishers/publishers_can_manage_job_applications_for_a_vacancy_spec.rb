require "rails_helper"

# runtime 33 seconds
# a total mixture of simple display tests and behaviour
# for complex ATS functionality
RSpec.describe "Publishers can manage job applications for a vacancy" do
  let(:organisation) { create(:school, name: "A school with a vacancy") }
  let!(:vacancy) { create(:vacancy, vacancy_trait, expires_at: expired_at, organisations: [organisation], job_applications: job_applications) }
  let(:publisher) { create(:publisher) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  context "when a vacancy has expired and it has applications" do
    let(:vacancy_trait) { :expired }
    let(:expired_at) { 2.weeks.ago }

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

    before { visit organisation_job_job_applications_path(vacancy.id) }

    describe "the summary section" do
      it "shows breadcrumb with link to passed deadline in dashboard" do
        within(".govuk-breadcrumbs") do
          expect(page).to have_link(I18n.t("jobs.dashboard.expired.tab_heading"), href: organisation_jobs_with_type_path(:expired))
        end
      end

      it "shows breadcrumbs with vacancy title" do
        within(".govuk-breadcrumbs") do
          expect(page).to have_content(vacancy.job_title)
        end
      end

      it "shows a card for each application that has been submitted and no draft applications" do
        # No JS - this is the 'all' tab
        expect(page.first(".govuk-table__body")).to have_css(".govuk-table__row", count: 6)
      end
    end

    scenario "not selecting anything", :js do
      # Wait for page to fully load
      expect(page).to have_button(I18n.t("publishers.vacancies.job_applications.candidates.update_application_status"), wait: 10)

      click_on I18n.t("publishers.vacancies.job_applications.candidates.update_application_status")
      expect(page).to have_content(I18n.t("activemodel.errors.models.publishers/job_application/tag_form.attributes.job_applications.too_short"), wait: 5)
    end

    scenario "Changing multiple statuses at once", :js do
      # Wait for page to fully load
      find_by_id("tab_all-6")

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

    scenario "Changing a single status", :js do
      expect(page).to have_button(I18n.t("publishers.vacancies.job_applications.candidates.update_application_status"), wait: 10)
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

    describe "submitted application" do
      let(:status) { "submitted" }

      it "shows applicant name that links to application" do
        within(first(".application-#{status}")) do
          expect(page).to have_link("#{job_application_submitted.first_name} #{job_application_submitted.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_submitted.id))
        end
      end

      it "shows blue submitted tag" do
        within(first(".application-#{status}")) do
          expect(page).to have_css(".govuk-tag--blue", text: "unread")
        end
      end
    end

    describe "reviewed application", :js do
      let(:status) { "reviewed" }

      before { find(".application-#{status}") } # Wait for the page to fully load }

      it "shows applicant name that links to application" do
        within(".application-#{status}") do
          expect(page).to have_link("#{job_application_reviewed.first_name} #{job_application_reviewed.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_reviewed.id))
        end
      end

      it "shows purple reviewed tag" do
        within(".application-#{status}") do
          expect(page).to have_css(".govuk-tag--purple", text: "reviewed")
        end
      end
    end

    describe "shortlisted application", :js do
      it "shows applicant name that links to application and green shortlisted tag" do
        expect(page).to have_css(".application-shortlisted", wait: 10) # Wait for the page to fully load

        within(".application-shortlisted") do
          expect(page).to have_css(".govuk-tag--green", text: "shortlisted")
          expect(page).to have_link("#{job_application_shortlisted.first_name} #{job_application_shortlisted.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_shortlisted.id))
        end
      end
    end

    describe "unsuccessful application" do
      let(:status) { "unsuccessful" }

      it "shows applicant name that links to application", :js do
        expect(page).to have_css(".application-#{status}", wait: 10) # Wait for the page to fully load

        within(".application-#{status}") do
          expect(page).to have_link("#{job_application_unsuccessful.first_name} #{job_application_unsuccessful.last_name}",
                                    href: organisation_job_job_application_path(vacancy.id, job_application_unsuccessful.id),
                                    wait: 10)
        end
      end

      it "shows red rejected tag", :js do
        expect(page).to have_css(".application-#{status}", wait: 10) # Wait for the page to fully load

        within(".application-#{status}") do
          expect(page).to have_css(".govuk-tag--red", text: "rejected", wait: 5)
        end
      end
    end
  end

  context "when a vacancy is active and it has no applications" do
    let(:vacancy_trait) { :published }
    let(:job_applications) { [] }
    let(:expired_at) { 1.month.from_now }

    before { visit organisation_job_job_applications_path(vacancy.id) }

    describe "the summary section" do
      it "shows breadcrumb with link to active jobs in dashboard" do
        within(".govuk-breadcrumbs") do
          expect(page).to have_link(I18n.t("jobs.dashboard.published.tab_heading"), href: organisation_jobs_with_type_path(:live))
        end
      end

      it "shows breadcrumbs with vacancy title" do
        within(".govuk-breadcrumbs") do
          expect(page).to have_content(vacancy.job_title)
        end
      end

      it "shows that there are no applicants" do
        expect(page).to have_css(".empty-section-component h3", text: I18n.t("publishers.vacancies.job_applications.index.no_applicants"))
      end
    end
  end

  context "when a vacancy has expired more than 1 year ago and it has applications" do
    let(:vacancy_trait) { :expired }
    let(:expired_at) { 1.year.ago }
    let(:job_applications) { build_list(:job_application, 1, :status_submitted) }

    before { visit organisation_job_job_applications_path(vacancy.id) }

    describe "the summary section" do
      it "shows no application cards" do
        expect(page).not_to have_css(".govuk-table__row")
      end

      it "shows text to tell user can no longer see applications" do
        expect(page).to have_css(".govuk-inset-text p", text: I18n.t("publishers.vacancies.job_applications.index.expired_more_than_year"))
      end
    end
  end
end
