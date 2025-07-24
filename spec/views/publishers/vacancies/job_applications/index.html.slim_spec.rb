require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/index" do
  let(:organisation) { build_stubbed(:school) }
  let(:publisher) { build_stubbed(:publisher, organisations: [organisation]) }
  let(:vacancy) { build_stubbed(:vacancy, publisher: publisher, organisations: [organisation]) }
  let(:submitted) do
    [
      build_stubbed(:job_application, :status_submitted, vacancy:),
      build_stubbed(:job_application, :status_reviewed, vacancy:),
    ]
  end
  let(:unsuccessful) { build_stubbed_list(:job_application, 1, :status_unsuccessful, vacancy:) }
  let(:shortlisted) { build_stubbed_list(:job_application, 1, :status_shortlisted, vacancy:) }
  let(:interviewing) { build_stubbed_list(:job_application, 1, :status_interviewing, vacancy:) }
  let(:withdrawn) { build_stubbed_list(:job_application, 1, :status_withdrawn, vacancy:) }
  let(:all) { withdrawn + submitted + unsuccessful + shortlisted + interviewing }
  let(:candidates) { { all:, submitted:, unsuccessful:, shortlisted:, interviewing: }.stringify_keys }
  let(:tab_headers) do
    [
      ["all", all.count],
      ["submitted", submitted.count],
      ["unsuccessful", unsuccessful.count],
      ["shortlisted", shortlisted.count],
      ["interviewing", interviewing.count],
    ]
  end

  before do
    assign :current_organisation, organisation
    assign :vacancy, vacancy
    assign :form, Publishers::JobApplication::TagForm.new
    assign :candidates, candidates
    assign :tab_headers, tab_headers

    render
  end

  it "shows a status 'tag' of 'unread'" do
    expect(rendered).to have_css(".govuk-tag", text: "unread")
  end

  it "has a link to view the application" do
    job_application = submitted.first
    expect(rendered).to have_link(job_application.name, href: organisation_job_job_application_path(job_application, job_id: vacancy.id))
  end

  context "when a vacancy has expired and it has applications" do
    let(:vacancy) { build_stubbed(:vacancy, :expired, expires_at: 2.weeks.ago, organisations: [organisation]) }

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
      let(:candidate) { submitted.first }

      it "shows applicant name that links to application" do
        within(".application-#{status}") do
          expect(rendered).to have_link("#{candidate.first_name} #{candidate.last_name}", href: organisation_job_job_application_path(vacancy.id, candidate.id))
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
      let(:candidate) { submitted.last }

      it "shows applicant name that links to application" do
        within(".application-#{status}") do
          expect(rendered).to have_link("#{candidate.first_name} #{candidate.last_name}", href: organisation_job_job_application_path(vacancy.id, candidate.id))
        end
      end

      it "shows purple reviewed tag" do
        within(".application-#{status}") do
          expect(rendered).to have_css(".govuk-tag--purple", text: "reviewed")
        end
      end
    end

    describe "shortlisted application" do
      let(:candidate) { shortlisted.first }

      it "shows applicant name that links to application and green shortlisted tag" do
        expect(rendered).to have_css(".application-shortlisted")

        within(".application-shortlisted") do
          expect(rendered).to have_css(".govuk-tag--green", text: "shortlisted")
          expect(rendered).to have_link("#{candidate.first_name} #{candidate.last_name}", href: organisation_job_job_application_path(vacancy.id, candidate.id))
        end
      end
    end

    describe "unsuccessful application" do
      let(:status) { "unsuccessful" }
      let(:candidate) { unsuccessful.first }

      it "shows applicant name that links to application" do
        expect(rendered).to have_css(".application-#{status}")

        within(".application-#{status}") do
          expect(rendered).to have_link("#{candidate.first_name} #{candidate.last_name}", href: organisation_job_job_application_path(vacancy.id, candidate.id))
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
    let(:submitted) { [] }
    let(:unsuccessful) { [] }
    let(:shortlisted) { [] }
    let(:interviewing) { [] }
    let(:withdrawn) { [] }

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
        expect(rendered).to have_css(".empty-section-component h3", text: "Nobody has applied for this job yet")
      end
    end
  end

  context "when a vacancy has expired more than 1 year ago and it has applications" do
    let(:vacancy) { build_stubbed(:vacancy, :expired, expires_at: 1.year.ago, organisations: [organisation]) }

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
