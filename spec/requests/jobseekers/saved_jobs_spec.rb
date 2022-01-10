require "rails_helper"

RSpec.describe "Saved jobs" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:jobseeker) { create(:jobseeker) }

  before { sign_in(jobseeker, scope: :jobseeker) }

  describe "GET #new" do
    it "saves a job" do
      expect { get new_jobseekers_saved_job_path(vacancy.id) }.to change { SavedJob.count }.by(1)
    end

    it "redirects to `job_path`" do
      expect(get(new_jobseekers_saved_job_path(vacancy.id))).to redirect_to(job_path(vacancy))
    end
  end

  describe "DELETE #destroy" do
    let!(:saved_job) { create(:saved_job, jobseeker:, vacancy:) }

    context "when `redirect_to_dashboard` param is true" do
      it "redirects to `jobseekers_saved_jobs_path`" do
        expect(delete(jobseekers_saved_job_path(vacancy.id, saved_job), params: { redirect_to_dashboard: "true" }))
          .to redirect_to(jobseekers_saved_jobs_path)
      end
    end

    context "when `redirect_to_dashboard` param is not true" do
      let(:params) { { redirect_to_dashboard: "true" } }

      it "redirects to `job_path`" do
        expect(delete(jobseekers_saved_job_path(vacancy.id, saved_job))).to redirect_to(job_path(vacancy))
      end
    end
  end
end
