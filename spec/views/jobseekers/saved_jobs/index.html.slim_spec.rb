require "rails_helper"

RSpec.describe "jobseekers/saved_jobs/index" do
  let(:jobseeker) { build_stubbed(:jobseeker) }
  let(:organisation) { build_stubbed(:school) }

  let(:vacancy_with_enabled_false) { build_stubbed(:vacancy, enable_job_applications: false, organisations: [organisation]) }
  let(:vacancy_with_enabled_true) { build_stubbed(:vacancy, enable_job_applications: true, organisations: [organisation]) }
  let(:expired_vacancy) { build_stubbed(:vacancy, :expired, organisations: [organisation]) }
  let(:expired_external_vacancy) { build_stubbed(:vacancy, :external, :expired, :trashed, organisations: [organisation]) }

  let(:sort) { Jobseekers::SavedJobSort.new }

  before do
    allow(view).to receive(:sort).and_return(sort)

    assign(:saved_jobs, saved_jobs)
    render
  end

  context "when there are saved jobs" do
    let(:saved_jobs) do
      [
        build_stubbed(:saved_job, vacancy: expired_external_vacancy),
        build_stubbed(:saved_job, vacancy: expired_vacancy),
        build_stubbed(:saved_job, vacancy: vacancy_with_enabled_true),
        build_stubbed(:saved_job, vacancy: vacancy_with_enabled_false),
      ]
    end

    context "when viewing saved jobs" do
      it "shows saved jobs" do
        expect(rendered).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
        expect(rendered).to have_css("h1.govuk-heading-l", text: I18n.t("jobseekers.saved_jobs.index.page_title"))
        expect(rendered).to have_css(".card-component", count: 4)

        within ".card-component:nth-child(2)" do
          expect(rendered).to have_css(".card-component__header", text: expired_vacancy.job_title)
        end

        within ".card-component:nth-child(3)" do
          expect(rendered).to have_css(".card-component__header", text: vacancy2.job_title)
        end

        within ".card-component:nth-child(4)" do
          expect(rendered).to have_css(".card-component__header", text: vacancy1.job_title)
        end
      end

      it "shows job closed label for expired jobs" do
        within ".card-component:nth-child(2)" do
          expect(rendered).to have_css(".card-component__body", text: I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
        end

        within ".card-component:nth-child(3)" do
          expect(rendered).to have_no_css(".card-component__body", text: I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
        end

        within ".card-component:nth-child(4)" do
          expect(rendered).to have_no_css(".card-component__body", text: I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
        end
      end

      it "only allows jobseekers to apply for jobs that have not expired" do
        within ".card-component:nth-child(2)" do
          expect(rendered).to have_no_link(I18n.t("jobseekers.saved_jobs.index.apply"))
        end

        within ".card-component:nth-child(3)" do
          expect(rendered).to have_link(I18n.t("jobseekers.saved_jobs.index.apply"))
        end

        within ".card-component:nth-child(4)" do
          expect(rendered).to have_no_link(I18n.t("jobseekers.saved_jobs.index.apply"))
        end
      end
    end
  end

  context "when there are no saved jobs" do
    let(:saved_jobs) { [] }

    it "shows zero saved jobs" do
      expect(rendered).to have_content(I18n.t("jobseekers.saved_jobs.index.zero_saved_jobs_title"))
    end
  end
end
