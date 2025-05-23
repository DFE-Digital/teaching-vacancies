require "rails_helper"

RSpec.describe "Job applications references" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }
  let(:referee) { create(:referee, job_application: job_application) }

  before do
    sign_in(jobseeker, scope: :jobseeker)
  end

  after { sign_out(jobseeker) }

  describe "GET #new" do
    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "returns not_found" do
        get new_jobseekers_job_application_referee_path(job_application)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the new page" do
      expect(get(new_jobseekers_job_application_referee_path(job_application)))
        .to render_template(:new)
    end
  end

  describe "GET #edit" do
    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "returns not_found" do
        get edit_jobseekers_job_application_referee_path(job_application, referee)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the edit page" do
      expect(get(edit_jobseekers_job_application_referee_path(job_application, referee)))
        .to render_template(:edit)
    end
  end

  describe "POST #create" do
    let(:params) { { jobseekers_job_application_details_referee_form: { name: name } } }
    let(:name) { "Reference Bloggs" }

    context "when the form is valid" do
      before { allow_any_instance_of(Jobseekers::JobApplication::Details::RefereeForm).to receive(:valid?).and_return(true) }

      it "creates the reference and redirects to the references build step" do
        expect { post jobseekers_job_application_referees_path(job_application), params: params }
          .to change(Referee, :count).by(1)

        expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :referees))
      end

      context "when the job application status is not draft" do
        let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

        it "returns not_found" do
          post jobseekers_job_application_referees_path(job_application), params: params

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the form is invalid" do
      it "does not create the reference and renders the new page" do
        expect { post jobseekers_job_application_referees_path(job_application), params: params }
          .to(not_change { Referee.count })

        expect(response).to render_template(:new)
      end
    end
  end

  describe "PATCH #update" do
    let!(:referee) { create(:referee, job_application: job_application, name: "Testing Bloggs") }
    let(:params) { { jobseekers_job_application_details_referee_form: { name: name } } }
    let(:name) { "Reference Bloggs" }

    context "when the form is valid" do
      before { allow_any_instance_of(Jobseekers::JobApplication::Details::RefereeForm).to receive(:valid?).and_return(true) }

      it "updates the reference and redirects to the references build step" do
        expect { patch jobseekers_job_application_referee_path(job_application, referee), params: params }
          .to change { referee.reload.name }.from("Testing Bloggs").to("Reference Bloggs")

        expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :referees))
      end

      context "when the job application status is not draft" do
        let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

        it "returns not_found" do
          patch jobseekers_job_application_referee_path(job_application, referee), params: params

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the form is invalid" do
      it "does not update the reference and renders the edit page" do
        expect { patch jobseekers_job_application_referee_path(job_application, referee), params: params }
          .to(not_change { referee.reload.name })

        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:referee) { create(:referee, job_application: job_application) }

    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "returns not_found" do
        delete jobseekers_job_application_referee_path(job_application, referee)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "destroys the reference and redirects to the references build step" do
      expect { delete jobseekers_job_application_referee_path(job_application, referee) }
        .to change(Referee, :count).by(-1)

      expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :referees))
    end
  end
end
