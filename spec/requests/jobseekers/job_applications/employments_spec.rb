require "rails_helper"

RSpec.describe "Job applications employments" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }
  let(:employment) { create(:employment, job_application: job_application) }

  before do
    sign_in(jobseeker, scope: :jobseeker)
  end

  after { sign_out(jobseeker) }

  describe "GET #new" do
    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

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
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

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

  describe "changing data" do
    let(:organisation) { "Awesome academy" }
    let(:job_title) { "Number 9" }
    let(:ended_on_month) { "01" }
    let(:started_on_year) { "2001" }
    let(:ended_on_year) { "2002" }
    let(:main_duties) { "Scoring goals" }
    let(:reason_for_leaving) { "relocating" }
    let(:base_params) do
      {
        organisation: organisation,
        job_title: job_title,
        "started_on(2i)": started_on_month,
        "started_on(1i)": started_on_year,
        main_duties: main_duties,
        reason_for_leaving: reason_for_leaving,
      }
    end

    describe "POST #create" do
      let(:params) do
        {
          jobseekers_job_application_details_employment_form:
            base_params.merge(is_current_role: "true"),
        }
      end

      context "when the form is valid" do
        let(:started_on_month) { "12" }

        it "creates the employment and redirects to the employment history build step" do
          expect { post jobseekers_job_application_employments_path(job_application), params: params }
            .to change { Employment.count }.by(1)

          expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :employment_history))
          expect(Employment.order(:created_at).last.is_current_role).to be(true)
        end

        context "when the job application status is not draft" do
          let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

          it "returns not_found" do
            post jobseekers_job_application_employments_path(job_application), params: params

            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "when the form is invalid" do
        let(:started_on_month) { "15" }

        it "does not create the employment and renders the new page" do
          expect { post jobseekers_job_application_employments_path(job_application), params: params }
            .to(not_change { Employment.count })

          expect(response).to render_template(:new)
        end
      end
    end

    describe "PATCH #update" do
      let!(:employment) { create(:employment, :current_role, job_application: job_application, organisation: "Cool school") }
      let(:organisation) { "Awesome academy" }
      let(:params) do
        {
          jobseekers_job_application_details_employment_form:
            base_params.merge(is_current_role: "false", "ended_on(2i)": ended_on_month,
                              "ended_on(1i)": ended_on_year),
        }
      end

      context "when the form is valid" do
        let(:started_on_month) { "12" }

        it "updates the employment and redirects to the employment history build step" do
          expect { patch jobseekers_job_application_employment_path(job_application, employment), params: params }
            .to change { employment.reload.organisation }.from("Cool school").to("Awesome academy")

          expect(employment.is_current_role?).to be(false)
          expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :employment_history))
        end

        context "when the job application status is not draft" do
          let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

          it "returns not_found" do
            patch jobseekers_job_application_employment_path(job_application, employment), params: params

            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "when the form is invalid" do
        let(:started_on_month) { "15" }

        it "does not update the employment and renders the edit page" do
          expect { patch jobseekers_job_application_employment_path(job_application, employment), params: params }
            .to(not_change { employment.reload.organisation })

          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:employment) { create(:employment, job_application: job_application) }

    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

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
