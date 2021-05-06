require "rails_helper"

RSpec.describe "Job applications qualifications" do
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }
  let(:qualification) { create(:qualification, job_application: job_application) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    sign_in(jobseeker, scope: :jobseeker)
  end

  describe "GET #select_category" do
    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "returns not_found" do
        get select_category_jobseekers_job_application_qualifications_path(job_application)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the new page" do
      expect(get(select_category_jobseekers_job_application_qualifications_path(job_application)))
        .to render_template(:select_category)
    end
  end

  describe "POST #submit_category" do
    let(:params) do
      { commit: I18n.t("buttons.continue"), jobseekers_job_application_details_qualifications_category_form: { category: "other" } }
    end

    context "when the form is valid" do
      before { allow_any_instance_of(Jobseekers::JobApplication::Details::Qualifications::CategoryForm).to receive(:valid?).and_return(true) }

      it "does not create a qualification and renders the next step" do
        expect { post submit_category_jobseekers_job_application_qualifications_path(job_application), params: params }
          .to(not_change { Qualification.count })

        expect(response).to redirect_to(new_jobseekers_job_application_qualification_path(job_application, category: "other"))
      end
    end

    context "when the form is invalid" do
      before { allow_any_instance_of(Jobseekers::JobApplication::Details::Qualifications::CategoryForm).to receive(:valid?).and_return(false) }

      it "does not create a qualification and renders the select_category page" do
        expect { post submit_category_jobseekers_job_application_qualifications_path(job_application), params: params }
          .to(not_change { Qualification.count })

        expect(response).to render_template(:select_category)
      end
    end
  end

  describe "GET #new" do
    let(:params) { { category: "gcse" } }

    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "returns not_found" do
        get new_jobseekers_job_application_qualification_path(job_application), params: params

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the new page" do
      expect(get(new_jobseekers_job_application_qualification_path(job_application), params: params))
        .to render_template(:new)
    end
  end

  describe "GET #edit" do
    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "returns not_found" do
        get edit_jobseekers_job_application_qualification_path(job_application, qualification)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the edit page" do
      expect(get(edit_jobseekers_job_application_qualification_path(job_application, qualification)))
        .to render_template(:edit)
    end
  end

  describe "POST #create" do
    let(:params) do
      { commit: button, category: "undergraduate", jobseekers_job_application_details_qualifications_degree_form: { subject: "Scaring" } }
    end
    let(:button) { I18n.t("buttons.save_qualification.one") }

    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "returns not_found" do
        post jobseekers_job_application_qualifications_path(job_application), params: params

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the form is valid" do
      before { allow_any_instance_of(Jobseekers::JobApplication::Details::Qualifications::DegreeForm).to receive(:valid?).and_return(true) }

      it "creates the qualification and redirects to the qualification build step" do
        expect { post jobseekers_job_application_qualifications_path(job_application), params: params }
          .to change { Qualification.count }.by(1)

        expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :qualifications))
      end
    end

    context "when the form is invalid" do
      it "does not create the qualification and renders the new page" do
        expect { post jobseekers_job_application_qualifications_path(job_application), params: params }
          .to(not_change { Qualification.count })

        expect(response).to render_template(:new)
      end
    end
  end

  describe "PATCH #update" do
    let!(:qualification) do
      create(:qualification, job_application: job_application,
                             category: "undergraduate",
                             finished_studying: original_finished_studying,
                             finished_studying_details: "Taking my time",
                             grade: "1",
                             subject: "Haunting",
                             year: 1990)
    end
    let(:original_finished_studying) { "true" }
    let(:params) do
      { commit: button, jobseekers_job_application_details_qualifications_degree_form: { subject: "Spooking", finished_studying: new_finished_studying } }
    end
    let(:new_finished_studying) { "true" }
    let(:button) { I18n.t("buttons.save_qualification.one") }

    context "when the form is valid" do
      before { allow_any_instance_of(Jobseekers::JobApplication::Details::Qualifications::DegreeForm).to receive(:valid?).and_return(true) }

      it "updates the qualification and redirects to the qualification build step" do
        expect { patch jobseekers_job_application_qualification_path(job_application, qualification), params: params }
          .to change { qualification.reload.subject }.from("Haunting").to("Spooking")

        expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :qualifications))
      end

      context "when changing finished_studying from true to false" do
        let(:new_finished_studying) { "false" }

        it "deletes the grade and year data from the record" do
          expect { patch jobseekers_job_application_qualification_path(job_application, qualification), params: params }
            .to change { qualification.reload.grade }.from("1").to("")
            .and change { qualification.reload.year }.from(1990).to(nil)
        end
      end

      context "when changing finished_studying from false to true" do
        let(:original_finished_studying) { "false" }
        let(:new_finished_studying) { "true" }

        it "deletes the finished_studying_details data from the record" do
          expect { patch jobseekers_job_application_qualification_path(job_application, qualification), params: params }
            .to change { qualification.reload.finished_studying_details }.from("Taking my time").to("")
        end
      end

      context "when the job application status is not draft" do
        let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

        it "returns not_found" do
          patch jobseekers_job_application_qualification_path(job_application, qualification), params: params

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when the form is invalid" do
      it "does not update the qualification and renders the edit page" do
        expect { patch jobseekers_job_application_qualification_path(job_application, qualification), params: params }
          .to(not_change { qualification.reload.subject })

        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:qualification) { create(:qualification, job_application: job_application) }

    context "when the job application status is not draft" do
      let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

      it "returns not_found" do
        delete jobseekers_job_application_qualification_path(job_application, qualification)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "destroys the qualification and redirects to the qualification build step" do
      expect { delete jobseekers_job_application_qualification_path(job_application, qualification) }
        .to change { Qualification.count }.by(-1)

      expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :qualifications))
    end
  end
end
