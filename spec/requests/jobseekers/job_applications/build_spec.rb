require "rails_helper"

RSpec.describe "Job applications build" do
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    sign_in(jobseeker, scope: :jobseeker)
  end

  describe "GET #show" do
    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "returns not_found" do
        get jobseekers_job_application_build_path(job_application, :personal_details)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the show page" do
      expect(get(jobseekers_job_application_build_path(job_application, :personal_details)))
        .to render_template(:personal_details)
    end
  end

  describe "PATCH #update" do
    let(:params) { { commit: button, origin: origin, jobseekers_job_application_personal_details_form: { first_name: "Cool name" } } }
    let(:button) { I18n.t("buttons.save_and_continue") }
    let(:origin) { "" }

    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "returns not_found" do
        patch jobseekers_job_application_build_path(job_application, :personal_details)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the commit param is `Save and come back later`" do
      let(:button) { I18n.t("buttons.save_and_come_back") }

      it "updates the job application without form validation and redirects to the dashboard" do
        expect { patch jobseekers_job_application_build_path(job_application, :personal_details), params: params }
          .to change { job_application.reload.first_name }.from("").to("Cool name")
          .and(not_change { job_application.reload.completed_steps })

        expect(response).to redirect_to(jobseekers_job_applications_path)
      end
    end

    context "when the form is valid" do
      before { allow_any_instance_of(Jobseekers::JobApplication::PersonalDetailsForm).to receive(:valid?).and_return(true) }

      context "when origin param is `jobseekers_job_application_review_url`" do
        let(:origin) { jobseekers_job_application_review_url(job_application) }

        it "updates the job application and redirects to the review page" do
          expect { patch jobseekers_job_application_build_path(job_application, :personal_details), params: params }
            .to change { job_application.reload.first_name }.from("").to("Cool name")
            .and change { job_application.reload.completed_steps }.from([]).to(["personal_details"])

          expect(response).to redirect_to(jobseekers_job_application_review_path(job_application))
        end
      end

      context "when origin param is not `jobseekers_job_application_review_url`" do
        it "updates the job application and redirects to the next step" do
          expect { patch jobseekers_job_application_build_path(job_application, :personal_details), params: params }
            .to change { job_application.reload.first_name }.from("").to("Cool name")
            .and change { job_application.reload.completed_steps }.from([]).to(["personal_details"])

          expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :professional_status))
        end
      end
    end

    context "when the form is invalid" do
      it "does not update the job application and renders show page" do
        expect { patch jobseekers_job_application_build_path(job_application, :personal_details), params: params }
          .to not_change { job_application.reload.first_name }
          .and(not_change { job_application.reload.completed_steps })

        expect(response).to render_template(:personal_details)
      end
    end
  end
end
