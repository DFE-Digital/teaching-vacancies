require "rails_helper"

RSpec.describe "Job applications", type: :request do
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:jobseeker) { create(:jobseeker) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    sign_in(jobseeker, scope: :jobseeker)
  end

  describe "GET #new" do
    it "triggers a `vacancy_apply_clicked` event" do
      expect { get new_jobseekers_job_job_application_path(vacancy.id) }
        .to have_triggered_event(:vacancy_apply_clicked)
        .and_data(vacancy_id: vacancy.id)
    end

    context "when an job application for the job already exists" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "redirects to `jobseekers_job_applications_path`" do
        expect(get(new_jobseekers_job_job_application_path(vacancy.id))).to redirect_to(jobseekers_job_applications_path)
      end
    end
  end

  describe "POST #create" do
    context "when an job application for the job already exists" do
      let!(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

      it "redirects to `jobseekers_job_applications_path`" do
        expect(post(jobseekers_job_job_application_path(vacancy.id))).to redirect_to(jobseekers_job_applications_path)
      end
    end
  end
end
