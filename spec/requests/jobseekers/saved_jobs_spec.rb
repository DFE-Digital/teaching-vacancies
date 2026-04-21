require "rails_helper"

RSpec.describe "Saved jobs" do
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }

  describe "GET #index" do
    context "when a jobseeker is not signed in" do
      before { get jobseekers_saved_jobs_path }

      it "redirects to the sign in page" do
        expect(response.location).to match(new_jobseeker_session_path)
      end
    end

    context "when a jobseeker is signed in" do
      before { sign_in(jobseeker, scope: :jobseeker) }

      after { sign_out(jobseeker) }

      context "when there are no saved jobs" do
        before { get jobseekers_saved_jobs_path }

        it "shows the zero saved jobs state" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(I18n.t("jobseekers.saved_jobs.index.zero_saved_jobs_title"))
        end
      end

      context "when there are saved jobs" do
        let(:school) { create(:school) }
        let(:vacancy_no_applications) { create(:vacancy, enable_job_applications: false, organisations: [school]) }
        let(:vacancy_with_applications) { create(:vacancy, enable_job_applications: true, organisations: [school]) }
        let(:expired_vacancy) { create(:vacancy, :expired, organisations: [school]) }

        before do
          jobseeker.saved_jobs.create!(vacancy: vacancy_no_applications)
          jobseeker.saved_jobs.create!(vacancy: vacancy_with_applications)
          jobseeker.saved_jobs.create!(vacancy: expired_vacancy)
          get jobseekers_saved_jobs_path
        end

        it "lists all saved job titles, the deadline passed label, and the apply link only for the vacancy with applications enabled" do
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(I18n.t("jobseekers.saved_jobs.index.page_title"))
          expect(response.body).to include(vacancy_no_applications.job_title)
          expect(response.body).to include(vacancy_with_applications.job_title)
          expect(response.body).to include(expired_vacancy.job_title)

          expect(response.body).to include(I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
          expect(response.body).to include(new_jobseekers_job_job_application_path(vacancy_with_applications.id))
        end
      end
    end
  end

  describe "GET #new" do
    context "when a jobseeker is signed in" do
      before { sign_in(jobseeker, scope: :jobseeker) }

      after { sign_out(jobseeker) }

      it "saves the job and redirects to `job_path`" do
        expect { get new_jobseekers_saved_job_path(vacancy.id) }.to change { SavedJob.count }.by(1)
        expect(response).to redirect_to(job_path(vacancy))
      end
    end

    context "when a jobseeker is not signed in" do
      before { get(new_jobseekers_saved_job_path(vacancy.id)) }

      it "redirects to the sign in page" do
        expect(response.location).to match(a_string_matching(new_jobseeker_session_path))
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:saved_job) { create(:saved_job, jobseeker: jobseeker, vacancy: vacancy) }

    context "when a jobseeker is signed in" do
      before { sign_in(jobseeker, scope: :jobseeker) }

      after { sign_out(jobseeker) }

      context "when `redirect_to_dashboard` param is true" do
        it "redirects to `jobseekers_saved_jobs_path` with a success message" do
          expect(delete(jobseekers_saved_job_path(vacancy.id, saved_job), params: { redirect_to_dashboard: "true" }))
            .to redirect_to(jobseekers_saved_jobs_path)
          follow_redirect!
          expect(response.body).to include(I18n.t("jobseekers.saved_jobs.destroy.success"))
        end
      end

      context "when `redirect_to_dashboard` param is not true" do
        it "redirects to `job_path`" do
          expect(delete(jobseekers_saved_job_path(vacancy.id, saved_job))).to redirect_to(job_path(vacancy))
        end
      end
    end

    context "when a jobseeker is not signed in" do
      before { get(new_jobseekers_saved_job_path(vacancy.id)) }

      it "redirects to the sign in page" do
        expect(response.location).to match(a_string_matching(new_jobseeker_session_path))
      end
    end
  end
end
