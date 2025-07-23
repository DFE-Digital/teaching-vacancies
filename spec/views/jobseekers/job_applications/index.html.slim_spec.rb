require "rails_helper"

RSpec.describe "jobseekers/job_applications/index" do
  let(:jobseeker) { create(:jobseeker) }
  let(:index_view) { Capybara.string(rendered) }
  let(:selectors) do
    {
      header: "h1",
      job_applications: "#applications-results .card-component",
      job_application_header: ".card-component__header a",
      job_application_tag: ".card-component__action .govuk-tag",
    }
  end

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_jobseeker).and_return(jobseeker.reload)
    end

    assign(:active_drafts, active_drafts)
    assign(:expired_drafts, expired_drafts)
    assign(:active_job_applications, active_job_applications)

    render
  end

  describe "job applications rendering" do
    context "when there is no job application" do
      let(:active_drafts) { [] }
      let(:expired_drafts) { [] }
      let(:active_job_applications) { [] }

      it "renders empty content" do
        expect(index_view).to have_css(selectors[:header], text: "Applications (0)")
        expect(index_view.all(selectors[:job_applications])).to be_empty
      end
    end

    context "when there are some job applications" do
      let(:active_draft_job) { build_stubbed(:vacancy) }
      let(:active_draft) { build_stubbed(:job_application, :status_draft, jobseeker:, vacancy: active_draft_job) }
      let(:active_drafts) { [active_draft] }
      let(:expired_draft) { build_stubbed(:job_application, :status_draft, jobseeker:, vacancy: vacancy_expired) }
      let(:expired_drafts) { [expired_draft] }
      let(:active_job_applications) do
        [build_stubbed(:job_application, :status_submitted, jobseeker:),
         build_stubbed(:job_application, :status_reviewed, jobseeker:)]
      end

      # let(:submitted) { create(:job_application, :status_submitted, jobseeker:) }
      # let(:reviewed) { create(:job_application, :status_reviewed, jobseeker:) }
      # let(:shortlisted) { create(:job_application, :status_shortlisted, jobseeker:) }
      # let(:unsuccessful) { create(:job_application, :status_unsuccessful, jobseeker:) }
      # let(:withdrawn) { create(:job_application, :status_withdrawn, jobseeker:) }
      # let(:interviewing) { create(:job_application, :status_interviewing, jobseeker:) }
      # let(:expired) { create(:job_application, :status_draft, jobseeker:, vacancy: vacancy_expired) }
      let(:vacancy_expired) { build_stubbed(:vacancy, :at_one_school, expires_at: 1.week.ago) }

      let(:job_applications) do
        [draft, submitted, reviewed, shortlisted, unsuccessful, withdrawn, interviewing, expired]
      end

      it "renders job application list" do
        expect(index_view).to have_css(selectors[:header], text: "Applications (4)")
        expect(index_view.all(selectors[:job_applications]).count).to eq(4)
      end

      describe "applications groups" do
        let(:groups) { index_view.all(selectors[:job_applications]) }

        it "renders draft applications group first" do
          expect(groups[0]).to have_css(selectors[:job_application_header], text: active_draft_job.job_title)
          expect(groups[0].find(selectors[:job_application_header])["href"]).to eq(jobseekers_job_application_apply_path(active_draft))
          expect(groups[0]).to have_css(selectors[:job_application_tag], text: "draft")
        end

        it "renders active applications group" do
          active_job_applications.each.with_index do |application, idx|
            expect(groups[idx + 1]).to have_css(selectors[:job_application_header], text: application.vacancy.job_title)
            expect(groups[idx + 1].find(selectors[:job_application_header])["href"]).to eq(jobseekers_job_application_path(application))
            if application.status == "reviewed"
              expect(groups[idx + 1]).to have_css(selectors[:job_application_tag], text: "submitted")
            else
              expect(groups[idx + 1]).to have_css(selectors[:job_application_tag], text: application.status)
            end
          end
        end

        it "renders expired applications group last" do
          expect(groups.last).to have_css(selectors[:job_application_header], text: vacancy_expired.job_title)
          expect(groups.last.find(selectors[:job_application_header])["href"]).to eq(jobseekers_job_application_apply_path(expired_draft))
          expect(groups.last).to have_css(selectors[:job_application_tag], text: "deadline passed")
        end
      end
    end
  end
end
