require "rails_helper"

RSpec.describe "Publishers can manage job applications for a vacancy" do
  let(:organisation) { create(:school, name: "A school with a vacancy") }
  let!(:vacancy) { create(:vacancy, vacancy_trait, organisations: [organisation]) }
  let(:publisher) { create(:publisher) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  context "when a vacancy has expired and it has applications" do
    let(:vacancy_trait) { :expired }

    let!(:job_application_submitted) { create(:job_application, :status_submitted, vacancy: vacancy, last_name: "Alpha") }
    let!(:job_application_reviewed) { create(:job_application, :status_reviewed, vacancy: vacancy, last_name: "Charlie") }
    let!(:job_application_shortlisted) { create(:job_application, :status_shortlisted, vacancy: vacancy, last_name: "Beta") }
    let!(:job_application_unsuccessful) { create(:job_application, :status_unsuccessful, vacancy: vacancy, last_name: "Delta") }
    let!(:job_application_draft) { create(:job_application, :status_draft, vacancy: vacancy) }

    before { visit organisation_job_job_applications_path(vacancy.id) }

    describe "the summary section" do
      it "shows breadcrumb with link to passed deadline in dashboard" do
        within(".govuk-breadcrumbs") do
          expect(page).to have_link(I18n.t("jobs.dashboard.expired.tab_heading"), href: jobs_with_type_organisation_path(:expired))
        end
      end

      it "shows breadcrumbs with vacancy title " do
        within(".govuk-breadcrumbs") do
          expect(page).to have_content(vacancy.job_title)
        end
      end

      it "shows a card for each application that has been submitted and no draft applications" do
        expect(page).to have_css(".card-component", count: 4)
      end

      context "when sorting the job applications by a virtual attribute" do
        before do
          click_on I18n.t("publishers.vacancies.job_applications.index.sort_by.applicant_last_name").humanize
        end

        it "sorts the job applications" do
          expect("Alpha").to appear_before("Beta")
          expect("Beta").to appear_before("Charlie")
          expect("Charlie").to appear_before("Delta")
        end
      end
    end

    describe "submitted application" do
      let(:status) { "submitted" }

      it "shows applicant name that links to application" do
        within(".application-#{status} .card-component__header") do
          expect(page).to have_link("#{job_application_submitted.first_name} #{job_application_submitted.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_submitted.id))
        end
      end

      it "shows blue submitted tag" do
        within(".application-#{status} .card-component__body") do
          expect(page).to have_css(".govuk-tag--blue", text: "unread")
        end
      end

      it "shows date application was received" do
        within(".application-#{status} .card-component__body") do
          expect(page).to have_content(job_application_submitted.submitted_at.strftime("%d %B %Y at %H:%M"))
        end
      end

      it "has action to reject application" do
        within(".application-#{status} .card-component__actions") do
          expect(page).to have_link(I18n.t("buttons.reject"), href: organisation_job_job_application_reject_path(vacancy.id, job_application_submitted.id))
        end
      end

      it "has action to shortlist application" do
        within(".application-#{status} .card-component__actions") do
          expect(page).to have_link(I18n.t("buttons.shortlist"), href: organisation_job_job_application_shortlist_path(vacancy.id, job_application_submitted.id))
        end
      end
    end

    describe "reviewed application" do
      let(:status) { "reviewed" }

      it "shows applicant name that links to application" do
        within(".application-#{status} .card-component__header") do
          expect(page).to have_link("#{job_application_reviewed.first_name} #{job_application_reviewed.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_reviewed.id))
        end
      end

      it "shows blue submitted tag" do
        within(".application-#{status} .card-component__body") do
          expect(page).to have_css(".govuk-tag--purple", text: "reviewed")
        end
      end

      it "shows date application was received" do
        within(".application-#{status} .card-component__body") do
          expect(page).to have_content(job_application_reviewed.submitted_at.strftime("%d %B %Y at %H:%M"))
        end
      end

      it "has action to reject application" do
        within(".application-#{status} .card-component__actions") do
          expect(page).to have_link(I18n.t("buttons.reject"), href: organisation_job_job_application_reject_path(vacancy.id, job_application_reviewed.id))
        end
      end

      it "has action to shortlist application" do
        within(".application-#{status} .card-component__actions") do
          expect(page).to have_link(I18n.t("buttons.shortlist"), href: organisation_job_job_application_shortlist_path(vacancy.id, job_application_reviewed.id))
        end
      end
    end

    describe "shortlisted application" do
      let(:status) { "shortlisted" }

      it "shows applicant name that links to application" do
        within(".application-#{status} .card-component__header") do
          expect(page).to have_link("#{job_application_shortlisted.first_name} #{job_application_shortlisted.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_shortlisted.id))
        end
      end

      it "shows green shortlisted tag" do
        within(".application-#{status} .card-component__body") do
          expect(page).to have_css(".govuk-tag--green", text: "shortlisted")
        end
      end

      it "shows date application was received" do
        within(".application-#{status} .card-component__body") do
          expect(page).to have_content(job_application_shortlisted.submitted_at.strftime("%d %B %Y at %H:%M"))
        end
      end

      it "has action to reject application only" do
        within(".application-#{status} .card-component__actions") do
          expect(page).to have_link(I18n.t("buttons.reject"), href: organisation_job_job_application_reject_path(vacancy.id, job_application_shortlisted.id))
          expect(page).not_to have_link(I18n.t("buttons.shortlist"), href: organisation_job_job_application_shortlist_path(vacancy.id, job_application_shortlisted.id))
        end
      end
    end

    describe "unsuccessful application" do
      let(:status) { "unsuccessful" }

      it "shows applicant name that links to application" do
        within(".application-#{status} .card-component__header") do
          expect(page).to have_link("#{job_application_unsuccessful.first_name} #{job_application_unsuccessful.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_unsuccessful.id))
        end
      end

      it "shows red shortlisted tag" do
        within(".application-#{status} .card-component__body") do
          expect(page).to have_css(".govuk-tag--red", text: "rejected")
        end
      end

      it "shows date application was received" do
        within(".application-#{status} .card-component__body") do
          expect(page).to have_content(job_application_unsuccessful.submitted_at.strftime("%d %B %Y at %H:%M"))
        end
      end

      it "has no actions" do
        within(".application-#{status} .card-component__actions") do
          expect(page).not_to have_link(I18n.t("buttons.reject"), href: organisation_job_job_application_reject_path(vacancy.id, job_application_unsuccessful.id))
          expect(page).not_to have_link(I18n.t("buttons.shortlist"), href: organisation_job_job_application_shortlist_path(vacancy.id, job_application_unsuccessful.id))
        end
      end
    end
  end

  context "when a vacancy is active and it has no applications" do
    let(:vacancy_trait) { :published }

    before { visit organisation_job_job_applications_path(vacancy.id) }

    describe "the summary section" do
      it "shows breadcrumb with link to active jobs in dashboard" do
        within(".govuk-breadcrumbs") do
          expect(page).to have_link(I18n.t("jobs.dashboard.published.tab_heading"), href: jobs_with_type_organisation_path(:published))
        end
      end

      it "shows breadcrumbs with vacancy title " do
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
    let!(:vacancy) { create(:vacancy, :expired, expires_at: 1.year.ago, organisations: [organisation]) }
    let!(:job_application_submitted) { create(:job_application, :status_submitted, vacancy: vacancy) }

    before { visit organisation_job_job_applications_path(vacancy.id) }

    describe "the summary section" do
      it "shows no application cards" do
        expect(page).not_to have_css(".card-component")
      end

      it "shows no sort applications control" do
        expect(page).not_to have_css("#sort-column-field")
      end

      it "shows text to tell user can no longer see applications" do
        expect(page).to have_css(".govuk-inset-text p", text: I18n.t("publishers.vacancies.job_applications.index.expired_more_than_year"))
      end
    end
  end
end
