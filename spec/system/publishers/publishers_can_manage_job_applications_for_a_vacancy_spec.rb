require "rails_helper"

RSpec.describe "Publishers can manage job applications for a vacancy" do
  let(:organisation) { create(:school, name: "A school with a vacancy") }
  let(:vacancy) { Vacancy.last }
  let(:publisher) { create(:publisher) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    create(:vacancy, vacancy_trait, expires_at: expired_at, organisations: [organisation], job_applications: job_applications)
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
       build(:job_application, :status_draft)]
    end
    let(:job_application_submitted) { JobApplication.find_by!(status: "submitted") }
    let(:job_application_reviewed) { JobApplication.find_by!(status: "reviewed") }
    let(:job_application_shortlisted) { JobApplication.find_by!(status: "shortlisted") }
    let(:job_application_unsuccessful) { JobApplication.find_by!(status: "unsuccessful") }
    let(:job_application_withdrawn) {  JobApplication.find_by!(status: "withdrawn") }

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

      it "shows a card for each application that has been submitted and no draft applications", :js do
        expect(page.find(".govuk-table__body")).to have_css(".govuk-table__row", count: 5)
      end
    end

    scenario "Changing multiple statuses at once", :js do
      within(".application-reviewed") do
        find(".govuk-checkboxes__item").click
      end
      within(".application-submitted") do
        find(".govuk-checkboxes__item").click
      end
      click_on I18n.t("publishers.vacancies.job_applications.candidates.update_application_status")
      find(".govuk-tag--red").click
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("Not Considering (3)")
    end

    scenario "Changing a single status", :js do
      within(".application-unsuccessful") do
        find(".govuk-checkboxes__item").click
      end
      click_on I18n.t("publishers.vacancies.job_applications.candidates.update_application_status")
      find(".govuk-tag--purple").click
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("New (3)")
    end

    describe "submitted application", :js do
      let(:status) { "submitted" }

      it "shows applicant name that links to application" do
        within(".application-#{status}") do
          expect(page).to have_link("#{job_application_submitted.first_name} #{job_application_submitted.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_submitted.id))
        end
      end

      it "shows blue submitted tag", :js do
        within(".application-#{status}") do
          expect(page).to have_css(".govuk-tag--blue", text: "unread")
        end
      end
    end

    describe "reviewed application" do
      let(:status) { "reviewed" }

      it "shows applicant name that links to application", :js do
        within(".application-#{status}") do
          expect(page).to have_link("#{job_application_reviewed.first_name} #{job_application_reviewed.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_reviewed.id))
        end
      end

      it "shows purple reviewed tag", :js do
        within(".application-#{status}") do
          expect(page).to have_css(".govuk-tag--purple", text: "reviewed")
        end
      end
    end

    describe "shortlisted application" do
      let(:status) { "shortlisted" }

      it "shows applicant name that links to application", :js do
        within(".application-#{status}") do
          expect(page).to have_link("#{job_application_shortlisted.first_name} #{job_application_shortlisted.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_shortlisted.id))
        end
      end

      it "shows green shortlisted tag", :js do
        within(".application-#{status}") do
          expect(page).to have_css(".govuk-tag--green", text: "shortlisted")
        end
      end
    end

    describe "unsuccessful application" do
      let(:status) { "unsuccessful" }

      it "shows applicant name that links to application", :js do
        within(".application-#{status}") do
          expect(page).to have_link("#{job_application_unsuccessful.first_name} #{job_application_unsuccessful.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_unsuccessful.id))
        end
      end

      it "shows red rejected tag", :js do
        within(".application-#{status}") do
          expect(page).to have_css(".govuk-tag--red", text: "rejected")
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
          expect(page).to have_link(I18n.t("jobs.dashboard.published.tab_heading"), href: organisation_jobs_with_type_path(:published))
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
