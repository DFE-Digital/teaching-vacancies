require "rails_helper"

RSpec.describe "Job applications qualifications" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }
  let(:qualification) { create(:qualification, job_application: job_application) }

  before do
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
      { jobseekers_job_application_details_qualifications_category_form: { category: "other" } }
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
    context "when creating a non-secondary qualification" do
      let(:params) do
        { category: "undergraduate", jobseekers_job_application_details_qualifications_degree_form: { subject: "Scaring" } }
      end

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

    context "when creating a secondary qualification" do
      let(:params) do
        { category: "gcse",
          jobseekers_job_application_details_qualifications_secondary_common_form: {
            category: "gcse",
            qualification_results_attributes: {
              "0": {
                subject: "Counting",
                grade: "A",
              },
              "1": {
                subject: "Singing",
                grade: result1_grade,
              },
              "2": {
                subject: "",
                grade: "",
              },
            },
          } }
      end
      let(:result1_grade) { "B" }

      context "when the parent and nested forms are valid" do
        before do
          allow_any_instance_of(Jobseekers::JobApplication::Details::Qualifications::Secondary::CommonForm).to receive(:valid?).and_return(true)
          allow_any_instance_of(Jobseekers::JobApplication::Details::Qualifications::Secondary::QualificationResultForm).to receive(:valid?).and_return(true)
        end

        it "creates the qualification with its results, and redirects to the qualification build step" do
          expect { post jobseekers_job_application_qualifications_path(job_application), params: params }
            .to change { Qualification.count }.by(1)
            .and change { QualificationResult.count }.by(2)

          expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :qualifications))
        end
      end

      context "when one of the nested forms is invalid" do
        let(:result1_grade) { "" }

        it "does not create the qualification or qualification results and renders the new page" do
          expect { post jobseekers_job_application_qualifications_path(job_application), params: params }
            .to(not_change { Qualification.count + QualificationResult.count })

          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe "PATCH #update" do
    context "when updating a non-secondary qualification" do
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
        { jobseekers_job_application_details_qualifications_degree_form: { subject: "Spooking", finished_studying: new_finished_studying } }
      end
      let(:new_finished_studying) { "true" }

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

    context "when updating a secondary qualification" do
      let!(:qualification) do
        create(:qualification, job_application: job_application,
                               category: "a_level",
                               institution: "Fancy School",
                               year: "1976")
      end
      let!(:result0) { qualification.qualification_results.first }
      let!(:result1) { qualification.qualification_results.second }
      let(:params) do
        { category: "a_level",
          jobseekers_job_application_details_qualifications_secondary_common_form: {
            category: "a_level",
            year: "2018",
            qualification_results_attributes: {
              "0": {
                id: result0.id,
                subject: "",
                grade: "",
              },
              "1": {
                id: result1.id,
                subject: result1_subject,
                grade: "#{result1.grade}*",
              },
              "2": {
                subject: "",
                grade: "",
              },
            },
          } }
      end
      let(:result1_subject) { result1.subject }

      context "when the parent and nested forms are valid" do
        before do
          allow_any_instance_of(Jobseekers::JobApplication::Details::Qualifications::Secondary::CommonForm).to receive(:valid?).and_return(true)
          allow_any_instance_of(Jobseekers::JobApplication::Details::Qualifications::Secondary::QualificationResultForm).to receive(:valid?).and_return(true)
        end

        it "updates the qualification and its results, and redirects to the qualification build step" do
          expect { patch jobseekers_job_application_qualification_path(job_application, qualification), params: params }
            .to change { [qualification.reload.qualification_results.count, qualification.reload.year, result1.reload.grade] }
            .from([5, 1976, result1.grade])
            .to([4, 2018, "#{result1.grade}*"])

          expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :qualifications))
        end
      end

      context "when one of the nested forms is invalid" do
        let(:result1_subject) { "" }

        it "does not create the qualification or qualification results and renders the edit page" do
          expect { patch jobseekers_job_application_qualification_path(job_application, qualification), params: params }
            .to(not_change { [qualification.reload.qualification_results.count, qualification.reload.year, result1.reload.grade] })

          expect(response).to render_template(:edit)
        end
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
