require "rails_helper"

RSpec.describe "Publishers can manage job applications for a vacancy" do
  let(:organisation) { create(:school, name: "A school with a vacancy") }
  let!(:vacancy) { create(:vacancy, vacancy_trait, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:publisher) { create(:publisher) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_publisher(publisher: publisher, organisation: organisation)
  end

  context "when a vacancy has expired and it has applications" do
    let(:vacancy_trait) { :expired }

    let!(:job_application_submitted) { create(:job_application, :status_submitted, vacancy: vacancy) }
    let!(:job_application_shortlisted) { create(:job_application, :status_shortlisted, vacancy: vacancy) }
    let!(:job_application_unsuccessful) { create(:job_application, :status_unsuccessful, vacancy: vacancy) }
    let!(:job_application_draft) { create(:job_application, :status_draft, vacancy: vacancy) }

    before { visit organisation_job_job_applications_path(vacancy.id) }

    describe "the summary section" do
      it "shows breadcrumb with link to passed deadline in dashboard" do
        within(".govuk-breadcrumbs") do
          expect(page).to have_link(I18n.t("publishers.vacancies_component.expired.tab_heading"), href: jobs_with_type_organisation_path(:expired))
        end
      end

      it "shows vacancy title and deadline passed" do
        within("h1") do
          expect(page).to have_content(vacancy.job_title)
        end

        within(".vacancy-deadline") do
          expect(page).to have_content(expiry_date_and_time(vacancy))
          expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.index.deadline.after"))
        end
      end

      it "shows total of each status for all applications" do
        within(".application-count.govuk-tag--green") do
          expect(page).to have_content("1")
          expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.index.shortlisted"))
        end

        within(".application-count.govuk-tag--blue") do
          expect(page).to have_content("1")
          expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.index.review"))
        end

        within(".application-count.govuk-tag--red") do
          expect(page).to have_content("1")
          expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.index.rejected"))
        end
      end

      it "shows a card for each application that has been submitted and no draft applications" do
        expect(page).to have_css(".card-component", count: 3)
      end

      it "shows correct vacancy actions available to the publisher" do
        within(".vacancy-actions") do
          expect(page).to have_css(".govuk-button", count: 2)
          expect(page).to have_link(I18n.t("publishers.vacancies.job_applications.buttons.copy"), href: organisation_job_copy_path(vacancy.id))
          expect(page).to have_link(I18n.t("buttons.extend_deadline"), href: organisation_job_extend_deadline_path(vacancy.id))
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
          expect(page).to have_css(".govuk-tag--blue", text: "review")
        end
      end

      it "shows date application was received" do
        within(".application-#{status} .card-component__body") do
          expect(page).to have_content(job_application_submitted.submitted_at)
        end
      end

      it "has action to reject application" do
        within(".application-#{status} .card-component__actions") do
          expect(page).to have_link(I18n.t("publishers.vacancies.job_applications.index.actions.reject"), href: organisation_job_job_application_reject_path(vacancy.id, job_application_submitted.id))
        end
      end

      it "has action to shortlist application" do
        within(".application-#{status} .card-component__actions") do
          expect(page).to have_link(I18n.t("publishers.vacancies.job_applications.index.actions.shortlist"), href: organisation_job_job_application_shortlist_path(vacancy.id, job_application_submitted.id))
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
          expect(page).to have_content(job_application_shortlisted.submitted_at)
        end
      end

      it "has action to reject application only" do
        within(".application-#{status} .card-component__actions") do
          expect(page).to have_link(I18n.t("publishers.vacancies.job_applications.index.actions.reject"), href: organisation_job_job_application_reject_path(vacancy.id, job_application_shortlisted.id))
          expect(page).not_to have_link(I18n.t("publishers.vacancies.job_applications.index.actions.shortlist"), href: organisation_job_job_application_shortlist_path(vacancy.id, job_application_shortlisted.id))
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
          expect(page).to have_content(job_application_unsuccessful.submitted_at)
        end
      end

      it "has no actions" do
        within(".application-#{status} .card-component__actions") do
          expect(page).not_to have_link(I18n.t("publishers.vacancies.job_applications.index.actions.reject"), href: organisation_job_job_application_reject_path(vacancy.id, job_application_unsuccessful.id))
          expect(page).not_to have_link(I18n.t("publishers.vacancies.job_applications.index.actions.shortlist"), href: organisation_job_job_application_shortlist_path(vacancy.id, job_application_unsuccessful.id))
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
          expect(page).to have_link(I18n.t("publishers.vacancies_component.published.tab_heading"), href: organisation_path)
        end
      end

      it "shows vacancy title and deadline date" do
        within("h1") do
          expect(page).to have_content(vacancy.job_title)
        end

        within(".vacancy-deadline") do
          expect(page).to have_content(expiry_date_and_time(vacancy))
          expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.index.deadline.before"))
        end
      end

      it "shows total of each status for all applications" do
        within(".application-count.govuk-tag--green") do
          expect(page).to have_content("0")
          expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.index.shortlisted"))
        end

        within(".application-count.govuk-tag--blue") do
          expect(page).to have_content("0")
          expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.index.review"))
        end

        within(".application-count.govuk-tag--red") do
          expect(page).to have_content("0")
          expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.index.rejected"))
        end
      end

      it "shows that there are no applicants" do
        expect(page).to have_css(".empty-section-component h3", text: I18n.t("publishers.vacancies.job_applications.index.no_applicants"))
      end

      it "shows correct vacancy actions available to the publisher" do
        within(".vacancy-actions") do
          expect(page).to have_css(".govuk-button", count: 4)
          expect(page).to have_link(I18n.t("publishers.vacancies.job_applications.buttons.copy"), href: organisation_job_copy_path(vacancy.id))
          expect(page).to have_link(I18n.t("publishers.vacancies.job_applications.buttons.edit"), href: edit_organisation_job_path(vacancy.id))
          expect(page).to have_link(I18n.t("publishers.vacancies.job_applications.buttons.end"), href: organisation_job_end_listing_path(vacancy.id))
          expect(page).to have_link(I18n.t("buttons.extend_deadline"), href: organisation_job_extend_deadline_path(vacancy.id))
        end
      end
    end
  end
end
