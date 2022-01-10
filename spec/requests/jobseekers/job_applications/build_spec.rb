require "rails_helper"

RSpec.describe "Job applications build" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker:, vacancy:) }

  before do
    sign_in(jobseeker, scope: :jobseeker)
  end

  describe "GET #show" do
    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker:, vacancy:) }

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
    let(:params) { { jobseekers_job_application_personal_details_form: { first_name: "Cool name" } } }

    context "when the form is valid" do
      before { allow_any_instance_of(Jobseekers::JobApplication::PersonalDetailsForm).to receive(:valid?).and_return(true) }

      context "when the jobseeker has previously submitted a job application" do
        let!(:job_application2) { create(:job_application, :status_submitted, jobseeker:) }
        let(:button) { I18n.t("buttons.save") }

        it "updates the job application and redirects to the review page" do
          expect { patch jobseekers_job_application_build_path(job_application, :personal_details), params: }
            .to change { job_application.reload.first_name }.from("").to("Cool name")
            .and change { job_application.completed_steps }.from([]).to(["personal_details"])

          expect(response).to redirect_to(jobseekers_job_application_review_path(job_application))
        end
      end

      context "when the jobseeker has not previously submitted a job application" do
        context "when coming from the review page" do
          let(:button) { I18n.t("buttons.save") }

          before { get jobseekers_job_application_review_path(job_application) }

          it "updates the job application and redirects to the review page" do
            expect { patch jobseekers_job_application_build_path(job_application, :personal_details), params: }
              .to change { job_application.reload.first_name }.from("").to("Cool name")
              .and change { job_application.completed_steps }.from([]).to(["personal_details"])

            expect(response).to redirect_to(jobseekers_job_application_review_path(job_application))
          end
        end

        context "when not coming from the review page" do
          it "updates the job application and redirects to the next step" do
            expect { patch jobseekers_job_application_build_path(job_application, :personal_details), params: }
              .to change { job_application.reload.first_name }.from("").to("Cool name")
              .and change { job_application.completed_steps }.from([]).to(["personal_details"])

            expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :professional_status))
          end
        end
      end

      context "when the job application status is not draft" do
        let(:job_application) { create(:job_application, :status_submitted, jobseeker:, vacancy:) }

        it "returns not_found" do
          patch jobseekers_job_application_build_path(job_application, :personal_details)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the form is invalid" do
      it "does not update the job application and renders show page" do
        expect { patch jobseekers_job_application_build_path(job_application, :personal_details), params: }
          .to not_change { job_application.reload.first_name }
          .and(not_change { job_application.completed_steps })

        expect(response).to render_template(:personal_details)
      end
    end
  end
end
