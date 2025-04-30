require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/index" do
  let(:organisation) { build_stubbed(:school) }
  let(:publisher) { build_stubbed(:publisher, organisations: [organisation]) }

  let(:vacancy) do
    build_stubbed(:vacancy, publisher: publisher, organisations: [organisation],
                            job_applications: [build_stubbed(:job_application, :submitted)])
  end
  let(:job_application) { vacancy.job_applications.first }

  before do
    assign :current_organisation, organisation
    assign :vacancy, vacancy
    assign :job_applications, vacancy.job_applications
    assign :form, Publishers::JobApplication::TagForm.new

    render
  end

  it "shows a status 'tag' of 'unread'" do
    expect(rendered).to have_css(".govuk-tag", text: "unread")
  end

  it "has a link to view the application" do
    expect(rendered).to have_link(job_application.name, href: organisation_job_job_application_path(job_application, job_id: vacancy.id))
  end

  context "when a vacancy has expired and it has applications" do
    let(:vacancy) do
      build_stubbed(:vacancy, :expired, expires_at: 2.weeks.ago, organisations: [organisation],
                                        job_applications: [
                                          job_application_submitted,
                                          job_application_reviewed,
                                          job_application_shortlisted,
                                          job_application_unsuccessful,
                                          job_application_withdrawn,
                                          job_application_interviewing,
                                        ])
    end

    let(:job_application_submitted) { build_stubbed(:job_application, :status_submitted, last_name: "Alan") }
    let(:job_application_reviewed) { build_stubbed(:job_application, :status_reviewed, last_name: "Charlie") }
    let(:job_application_shortlisted) { build_stubbed(:job_application, :status_shortlisted, last_name: "Billy") }
    let(:job_application_unsuccessful) { build_stubbed(:job_application, :status_unsuccessful, last_name: "Dave") }
    let(:job_application_withdrawn) {  build_stubbed(:job_application, :status_withdrawn, last_name: "Ethan") }
    let(:job_application_interviewing) { build_stubbed(:job_application, :status_interviewing, last_name: "Freddy") }

    describe "the summary section" do
      it "shows breadcrumb with link to passed deadline in dashboard" do
        within(".govuk-breadcrumbs") do
          expect(rendered).to have_link(I18n.t("jobs.dashboard.expired.tab_heading"), href: organisation_jobs_with_type_path(:expired))
        end
      end

      it "shows breadcrumbs with vacancy title" do
        within(".govuk-breadcrumbs") do
          expect(rendered).to have_content(vacancy.job_title)
        end
      end

      it "shows a card for each application that has been submitted" do
        # this is the 'all' tab
        within ".govuk-table__body" do
          expect(rendered).to have_css(".govuk-table__row", count: 6)
        end
      end
    end

    describe "submitted application" do
      let(:status) { "submitted" }

      it "shows applicant name that links to application" do
        within(".application-#{status}") do
          expect(rendered).to have_link("#{job_application_submitted.first_name} #{job_application_submitted.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_submitted.id))
        end
      end

      it "shows blue submitted tag" do
        within(".application-#{status}") do
          expect(rendered).to have_css(".govuk-tag--blue", text: "unread")
        end
      end
    end

    describe "reviewed application" do
      let(:status) { "reviewed" }

      it "shows applicant name that links to application" do
        within(".application-#{status}") do
          expect(rendered).to have_link("#{job_application_reviewed.first_name} #{job_application_reviewed.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_reviewed.id))
        end
      end

      it "shows purple reviewed tag" do
        within(".application-#{status}") do
          expect(rendered).to have_css(".govuk-tag--purple", text: "reviewed")
        end
      end
    end

    describe "shortlisted application" do
      it "shows applicant name that links to application and green shortlisted tag" do
        expect(rendered).to have_css(".application-shortlisted")

        within(".application-shortlisted") do
          expect(rendered).to have_css(".govuk-tag--green", text: "shortlisted")
          expect(rendered).to have_link("#{job_application_shortlisted.first_name} #{job_application_shortlisted.last_name}", href: organisation_job_job_application_path(vacancy.id, job_application_shortlisted.id))
        end
      end
    end

    describe "unsuccessful application" do
      let(:status) { "unsuccessful" }

      it "shows applicant name that links to application" do
        expect(rendered).to have_css(".application-#{status}")

        within(".application-#{status}") do
          expect(rendered).to have_link("#{job_application_unsuccessful.first_name} #{job_application_unsuccessful.last_name}",
                                        href: organisation_job_job_application_path(vacancy.id, job_application_unsuccessful.id))
        end
      end

      it "shows red rejected tag" do
        expect(rendered).to have_css(".application-#{status}")

        within(".application-#{status}") do
          expect(rendered).to have_css(".govuk-tag--red", text: "rejected")
        end
      end
    end
  end

  context "when a vacancy is active and it has no applications" do
    let(:vacancy) { build_stubbed(:vacancy, expires_at: 1.month.from_now, organisations: [organisation], job_applications: []) }

    describe "the summary section" do
      it "shows breadcrumb with link to active jobs in dashboard" do
        within(".govuk-breadcrumbs") do
          expect(rendered).to have_link(I18n.t("jobs.dashboard.published.tab_heading"), href: organisation_jobs_with_type_path(:live))
        end
      end

      it "shows breadcrumbs with vacancy title" do
        within(".govuk-breadcrumbs") do
          expect(rendered).to have_content(vacancy.job_title)
        end
      end

      it "shows that there are no applicants" do
        expect(rendered).to have_css(".empty-section-component h3", text: I18n.t("publishers.vacancies.job_applications.index.no_applicants"))
      end
    end
  end

  context "when a vacancy has expired more than 1 year ago and it has applications" do
    let(:vacancy) { build_stubbed(:vacancy, :expired, expires_at: 1.year.ago, organisations: [organisation], job_applications: build_stubbed_list(:job_application, 1, :status_submitted)) }

    describe "the summary section" do
      it "shows no application cards" do
        expect(rendered).to have_no_css(".govuk-table__row")
      end

      it "shows text to tell user can no longer see applications" do
        expect(rendered).to have_css(".govuk-inset-text p", text: I18n.t("publishers.vacancies.job_applications.index.expired_more_than_year"))
      end
    end
  end
end
