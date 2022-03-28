require "rails_helper"

RSpec.describe "Saved jobs" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:jobseeker) { create(:jobseeker) }

  describe "GET #new" do
    context "when a jobseeker is signed in" do
      before { sign_in(jobseeker, scope: :jobseeker) }

      it "saves a job" do
        expect { get new_jobseekers_saved_job_path(vacancy.id) }.to change { SavedJob.count }.by(1)
      end

      it "redirects to `job_path`" do
        expect(get(new_jobseekers_saved_job_path(vacancy.id))).to redirect_to(job_path(vacancy))
      end
    end

    context "when a jobseeker is not signed in" do
      before { get(new_jobseekers_saved_job_path(vacancy.id)) }

      it "redirects to the sign in page with a flash message explaining why" do
        follow_redirect!

        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:saved_job) { create(:saved_job, jobseeker: jobseeker, vacancy: vacancy) }

    before { sign_in(jobseeker, scope: :jobseeker) }

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
