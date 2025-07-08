require "rails_helper"

RSpec.describe "jobseekers/job_applications/index" do
  let(:jobseeker) { create(:jobseeker) }
  let(:index_view) { jobseeker_applications_page }

  before do
    job_applications
    without_partial_double_verification do
      allow(view).to receive(:current_jobseeker).and_return(jobseeker.reload)
    end

    render

    index_view.load(rendered)
  end

  describe "job applications rendering" do
    context "when there is no job application" do
      let(:job_applications) { nil }

      it "renders empty content" do
        expect(index_view.header).to have_text("Applications (0)")
        expect(index_view).to have_no_job_applications
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
      #let(:expired) { create(:job_application, :status_draft, jobseeker:) }

      let(:job_applications) do
        [draft, submitted, reviewed, shortlisted, unsuccessful, withdrawn, interviewing]
      end

      it "renders job application list" do
        expect(index_view.header).to have_text("Applications (7)")
        expect(index_view.job_applications.count).to eq(6)
      end

      it "renders draft applications group first" do
        expect(index_view.job_applications[0].header).to have_text(draft.vacancy.job_title)
        expect(index_view.job_applications[0].header["href"]).to eq(jobseekers_job_application_apply_path(draft))
        expect(index_view.job_applications[0].tag).to have_text(draft.status)
      end

      %i[submitted reviewed shortlisted unsuccessful withdrawn].each.with_index do |app, idx|
        it "renders #{app} applications group" do
          application = public_send(app)
          expect(index_view.job_applications[idx + 1].header).to have_text(application.vacancy.job_title)
          expect(index_view.job_applications[idx + 1].header["href"]).to eq(jobseekers_job_application_path(application))
          if app == :reviewed
            expect(index_view.job_applications[idx + 1].tag).to have_text("submitted")
          else
            expect(index_view.job_applications[idx + 1].tag).to have_text(application.status)
          end
        end
      end
    end
  end
end
