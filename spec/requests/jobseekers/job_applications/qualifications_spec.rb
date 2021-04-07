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
        get edit_jobseekers_job_application_qualifications_path(job_application, { ids: [qualification.id] })

        expect(response).to have_http_status(:not_found)
      end
    end

    it "renders the edit page" do
      expect(get edit_jobseekers_job_application_qualifications_path(job_application, { ids: [qualification.id] }))
        .to render_template(:edit)
    end
  end

  describe "POST #create" do
    context "when creating a single, non-secondary qualification" do
      let(:params) do
        { commit: I18n.t("buttons.save_qualification.one"), category: "undergraduate", jobseekers_job_application_details_qualifications_degree_form: { subject1: "Scaring" } }
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

          expect(job_application.reload.in_progress_steps).to contain_exactly("qualifications")
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

    context "when creating multiple secondary qualifications" do
      let(:params) do
        { commit: I18n.t("buttons.save_qualification.other"),
          category: "as_level",
          jobseekers_job_application_details_qualifications_secondary_common_form: {
            subject1: "Scaring", grade1: "A", subject2: "Spooking", grade2: "B"
          } }
      end

      context "when the form is valid" do
        before { allow_any_instance_of(Jobseekers::JobApplication::Details::Qualifications::Secondary::CommonForm).to receive(:valid?).and_return(true) }

        it "creates the qualifications and redirects to the qualification build step" do
          expect { post jobseekers_job_application_qualifications_path(job_application), params: params }
            .to change { Qualification.count }.by(2)

          expect(job_application.reload.in_progress_steps).to contain_exactly("qualifications")
          expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :qualifications))
        end
      end
    end
  end

  describe "PATCH #update" do
    context "when updating multiple secondary qualifications" do
      let(:subjects) { ["Tricycling", "Roller skating", "Ice skating", "Roller Derby"] }
      let(:grades) { %w[A B C D] }

      let!(:qualifications) do
        create_list(:qualification, 4,
                    category: "other_secondary",
                    institution: "Skating School",
                    job_application: job_application,
                    name: "Skates Certificate",
                    year: "2000") do |qualification, index|
          qualification.update_columns(subject: subjects[index], grade: grades[index])
        end
      end

      let(:params) do
        { commit: I18n.t("buttons.save_qualification.other"),
          ids: qualifications.pluck(:id),
          jobseekers_job_application_details_qualifications_secondary_other_form: {
            subject1: qualifications.first.subject,
            grade1: qualifications.first.grade,
            subject2: "#{qualifications.third.subject} studies",
            grade2: "#{qualifications.third.grade}+",
            subject3: "",
            grade3: "",
            category: "other_secondary",
            institution: institution_param,
            name: qualifications.first.name,
            year: qualifications.first.year,
          } }
      end

      let(:institution_param) { qualifications.first.institution }

      context "when keeping the 1st subject and grade the same, deleting the 2nd, editing the 3rd, and making the last row blank" do
        it "it replaces the third qualification, deletes the second and fourth, and redirects to the build step" do
          expect { patch jobseekers_job_application_qualifications_path(job_application), params: params }
            .to(not_change { [qualifications.first.reload.subject, qualifications.first.reload.grade] })

          expect(job_application.qualifications.count).to eq(2)
          expect(job_application.qualifications.pluck(:subject)).to contain_exactly("Tricycling", "Ice skating studies")
          expect(job_application.qualifications.pluck(:grade)).to contain_exactly("A", "C+")

          expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :qualifications))
        end

        context "when updating a form field shared by all qualifications" do
          let(:institution_param) { "Battersea School for Dogs" }

          it "performs the correct updates and redirects to the build step" do
            patch jobseekers_job_application_qualifications_path(job_application), params: params

            expect(job_application.qualifications.count).to eq(2)
            expect(job_application.qualifications.pluck(:subject)).to contain_exactly("Tricycling", "Ice skating studies")
            expect(job_application.qualifications.pluck(:grade)).to contain_exactly("A", "C+")
            expect(job_application.qualifications.pluck(:institution)).to contain_exactly(institution_param, institution_param)

            expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :qualifications))
          end
        end
      end
    end

    context "when updating a single, non-secondary qualification" do
      let!(:qualification) do
        create(:qualification, :skip_validate,
               job_application: job_application,
               category: "undergraduate",
               finished_studying: original_finished_studying,
               finished_studying_details: "I caught smallpox",
               grade: "100%",
               subject: "Haunting",
               year: 1990)
      end
      let(:params) do
        { commit: I18n.t("buttons.save_qualification.one"),
          ids: [qualification.id],
          jobseekers_job_application_details_qualifications_degree_form: base_form_params.merge(optional_params) }
      end
      let(:base_form_params) do
        {
          category: "undergraduate",
          finished_studying: finished_studying?.to_s,
          institution: qualification.institution,
          subject1: "Spooking",
        }
      end
      let(:optional_params) do
        if finished_studying?
          { grade1: qualification.grade, year: qualification.year }
        else
          { finished_studying_details: qualification.finished_studying_details }
        end
      end
      let(:original_finished_studying) { true }
      let(:finished_studying?) { original_finished_studying }

      context "when the job application status is not draft" do
        let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

        it "returns not_found" do
          patch jobseekers_job_application_qualifications_path(job_application), params: params

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the form is invalid" do
        before { allow_any_instance_of(Jobseekers::JobApplication::Details::Qualifications::DegreeForm).to receive(:valid?).and_return(false) }

        it "does not update the qualification and renders the edit page" do
          expect { patch jobseekers_job_application_qualifications_path(job_application), params: params }
            .to(not_change { job_application.qualifications.first.reload.subject })

          expect(response).to render_template(:edit)
        end
      end

      context "when updating the subject only" do
        it "updates the qualification and redirects to the qualification build step" do
          expect { patch jobseekers_job_application_qualifications_path(job_application), params: params }
            .to change { job_application.qualifications.first.reload.subject }.from("Haunting").to("Spooking")

          expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :qualifications))
        end
      end

      context "when changing finished_studying from true to false" do
        let(:finished_studying?) { false }

        it "deletes the grade and year data from the record" do
          expect { patch jobseekers_job_application_qualifications_path(job_application), params: params }
            .to change { job_application.qualifications.first.reload.grade }.from("100%").to("")
            .and change { job_application.qualifications.first.reload.year }.from(1990).to(nil)
        end
      end

      context "when changing finished_studying from false to true" do
        let(:original_finished_studying) { false }
        let(:finished_studying?) { true }

        it "deletes the finished_studying_details data from the record" do
          expect { patch jobseekers_job_application_qualifications_path(job_application), params: params }
            .to change { job_application.qualifications.first.reload.finished_studying_details }.from("I caught smallpox").to("")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when destroying a list of qualifications" do
      let!(:qualifications) { create_list(:qualification, 2, job_application: job_application) }

      context "when the job application status is not draft" do
        let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

        it "returns not_found" do
          delete destroy_jobseekers_job_application_qualifications_path(job_application), params: { ids: qualifications.pluck(:id) }

          expect(response).to have_http_status(:not_found)
        end
      end

      it "destroys the qualifications and redirects to the qualification build step" do
        expect { delete destroy_jobseekers_job_application_qualifications_path(job_application), params: { ids: qualifications.pluck(:id) } }
          .to change { Qualification.count }.by(-2)

        expect(response).to redirect_to(jobseekers_job_application_build_path(job_application, :qualifications))
      end
    end
  end
end
