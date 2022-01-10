require "rails_helper"

RSpec.describe "Job applications employments" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker:, vacancy:) }
  let(:employment) { create(:employment, job_application:) }

  before do
    sign_in(jobseeker, scope: :jobseeker)
  end

  describe "GET #new" do
    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker:, vacancy:) }

      it "returns not_found" do
        get new_jobseekers_job_application_employment_path(job_application)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the new page" do
      expect(get(new_jobseekers_job_application_employment_path(job_application)))
        .to render_template(:new)
    end
  end

  describe "GET #edit" do
    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker:, vacancy:) }

      it "returns not_found" do
        get edit_jobseekers_job_application_employment_path(job_application, employment)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the edit page" do
      expect(get(edit_jobseekers_job_application_employment_path(job_application, employment)))
        .to render_template(:edit)
    end
  end

  describe "POST #create" do
    let(:params) { { jobseekers_job_application_details_employment_form: { organisation: } } }
    let(:organisation) { "Awesome academy" }

    context "when the form is valid" do
      before { allow_any_instance_of(Jobseekers::JobApplication::Details::EmploymentForm).to receive(:valid?).and_return(true) }

      it "creates the employment and redirects to the employment history build step" do
        expect { post jobseekers_job_application_employments_path(job_application), params: }
          .to change { Employment.count }.by(1)

        expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :employment_history))
      end

      context "when the job application status is not draft" do
        let(:job_application) { create(:job_application, :status_submitted, jobseeker:, vacancy:) }

        it "returns not_found" do
          post jobseekers_job_application_employments_path(job_application), params: params

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the form is invalid" do
      it "does not create the employment and renders the new page" do
        expect { post jobseekers_job_application_employments_path(job_application), params: }
          .to(not_change { Employment.count })

        expect(response).to render_template(:new)
      end
    end
  end

  describe "PATCH #update" do
    let!(:employment) { create(:employment, job_application:, organisation: "Cool school") }
    let(:params) { { jobseekers_job_application_details_employment_form: { organisation: } } }
    let(:organisation) { "Awesome academy" }

    context "when the form is valid" do
      before { allow_any_instance_of(Jobseekers::JobApplication::Details::EmploymentForm).to receive(:valid?).and_return(true) }

      it "updates the employment and redirects to the employment history build step" do
        expect { patch jobseekers_job_application_employment_path(job_application, employment), params: }
          .to change { employment.reload.organisation }.from("Cool school").to("Awesome academy")

        expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :employment_history))
      end

      context "when the job application status is not draft" do
        let(:job_application) { create(:job_application, :status_submitted, jobseeker:, vacancy:) }

        it "returns not_found" do
          patch jobseekers_job_application_employment_path(job_application, employment), params: params

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the form is invalid" do
      it "does not update the employment and renders the edit page" do
        expect { patch jobseekers_job_application_employment_path(job_application, employment), params: }
          .to(not_change { employment.reload.organisation })

        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:employment) { create(:employment, job_application:) }

    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker:, vacancy:) }

      it "returns not_found" do
        delete jobseekers_job_application_employment_path(job_application, employment)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "destroys the employment and redirects to the employment history build step" do
      expect { delete jobseekers_job_application_employment_path(job_application, employment) }
        .to change { Employment.count }.by(-1)

      expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :employment_history))
    end
  end
end
