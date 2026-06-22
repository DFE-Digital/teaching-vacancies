require "rails_helper"

RSpec.describe "jobseekers/saved_jobs/index" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { build(:school) }

  let(:vacancy_with_enabled_false) { create(:vacancy, enable_job_applications: false, organisations: [organisation]) }
  let(:vacancy_with_enabled_true) { create(:vacancy, enable_job_applications: true, organisations: [organisation]) }
  let(:expired_vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:expired_external_vacancy) { create(:vacancy, :external, :expired, :trashed, organisations: [organisation]) }

  let(:sort) { Jobseekers::SavedJobSort.new }
  let(:page) { Capybara.string(rendered) }

  before do
    allow(view).to receive_messages(sort: sort, current_jobseeker: jobseeker)

    assign(:saved_jobs, saved_jobs)
    render
  end

  context "when there are saved jobs" do
    let(:saved_jobs) do
      [
        create(:saved_job, vacancy: expired_external_vacancy, jobseeker: jobseeker),
        create(:saved_job, vacancy: expired_vacancy, jobseeker: jobseeker),
        create(:saved_job, vacancy: vacancy_with_enabled_true, jobseeker: jobseeker),
        create(:saved_job, vacancy: vacancy_with_enabled_false, jobseeker: jobseeker),
      ]
    end

    context "when viewing saved jobs" do
      let(:second_child) { page.find(".card-component:nth-child(2)") }
      let(:third_child) { page.find(".card-component:nth-child(3)") }
      let(:fourth_child) { page.find(".card-component:nth-child(4)") }

      it "shows saved jobs" do
        expect(rendered).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
        expect(rendered).to have_css("h1.govuk-heading-l", text: I18n.t("jobseekers.saved_jobs.index.page_title"))
        expect(rendered).to have_css(".card-component", count: 4)

        expect(second_child).to have_css(".card-component__header", text: expired_vacancy.job_title)
        expect(third_child).to have_css(".card-component__header", text: vacancy_with_enabled_true.job_title)
        expect(fourth_child).to have_css(".card-component__header", text: vacancy_with_enabled_false.job_title)
      end

      it "shows job closed label for expired jobs" do
        expect(second_child).to have_css(".card-component__body", text: I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
        expect(third_child).to have_no_css(".card-component__body", text: I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
        expect(fourth_child).to have_no_css(".card-component__body", text: I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
      end

      it "only allows jobseekers to apply for jobs that have not expired" do
        expect(second_child).to have_no_link(I18n.t("jobseekers.saved_jobs.index.apply"))
        expect(third_child).to have_link(I18n.t("jobseekers.saved_jobs.index.apply"))
        expect(fourth_child).to have_no_link(I18n.t("jobseekers.saved_jobs.index.apply"))
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
