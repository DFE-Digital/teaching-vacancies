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
    job_applications
    without_partial_double_verification do
      allow(view).to receive(:current_jobseeker).and_return(jobseeker.reload)
    end

    render
  end

  describe "job applications rendering" do
    context "when there is no job application" do
      let(:job_applications) { nil }

      it "renders empty content" do
        expect(index_view).to have_css(selectors[:header], text: "Applications (0)")
        expect(index_view.all(selectors[:job_applications])).to be_empty
      end
    end

    context "when there are some job applications" do
      let(:draft) { create(:job_application, :status_draft, jobseeker:) }
      let(:submitted) { create(:job_application, :status_submitted, jobseeker:) }
      let(:reviewed) { create(:job_application, :status_reviewed, jobseeker:) }
      let(:shortlisted) { create(:job_application, :status_shortlisted, jobseeker:) }
      let(:unsuccessful) { create(:job_application, :status_unsuccessful, jobseeker:) }
      let(:withdrawn) { create(:job_application, :status_withdrawn, jobseeker:) }
      let(:interviewing) { create(:job_application, :status_interviewing, jobseeker:) }
      let(:expired) { create(:job_application, :status_draft, jobseeker:, vacancy: vacancy_expired) }
      let(:vacancy_expired) { create(:vacancy, :at_one_school, expires_at: 1.week.ago) }

      let(:job_applications) do
        [draft, submitted, reviewed, shortlisted, unsuccessful, withdrawn, interviewing, expired]
      end

      it "renders job application list" do
        expect(index_view).to have_css(selectors[:header], text: "Applications (8)")
        expect(index_view.all(selectors[:job_applications]).count).to eq(7)
      end

      describe "applications groups" do
        let(:groups) { index_view.all(selectors[:job_applications]) }

        it "renders draft applications group first" do
          expect(groups[0]).to have_css(selectors[:job_application_header], text: draft.vacancy.job_title)
          # expect(groups[0]).to have_link(selectors[:job_application_header], href: jobseekers_job_application_apply_path(draft))
          expect(groups[0].find(selectors[:job_application_header])["href"]).to eq(jobseekers_job_application_apply_path(draft))
          expect(groups[0]).to have_css(selectors[:job_application_tag], text: draft.status)
        end

        %i[submitted reviewed shortlisted unsuccessful withdrawn].each.with_index do |app, idx|
          it "renders #{app} applications group" do
            application = public_send(app)
            expect(groups[idx + 1]).to have_css(selectors[:job_application_header], text: application.vacancy.job_title)
            expect(groups[idx + 1].find(selectors[:job_application_header])["href"]).to eq(jobseekers_job_application_path(application))
            if app == :reviewed
              expect(groups[idx + 1]).to have_css(selectors[:job_application_tag], text: "submitted")
            else
              expect(groups[idx + 1]).to have_css(selectors[:job_application_tag], text: application.status)
            end
          end
        end

        it "renders expired applications group last" do
          expect(groups.last).to have_css(selectors[:job_application_header], text: expired.vacancy.job_title)
          expect(groups.last.find(selectors[:job_application_header])["href"]).to eq(jobseekers_job_application_apply_path(expired))
          expect(groups.last).to have_css(selectors[:job_application_tag], text: "deadline passed")
        end
      end
    end
  end
end
