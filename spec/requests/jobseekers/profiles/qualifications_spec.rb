require "rails_helper"

RSpec.describe "Jobseeker profile qualifications" do
  let(:jobseeker) { create(:jobseeker) }
  let!(:profile) { create(:jobseeker_profile, jobseeker:) }

  before { sign_in(jobseeker, scope: :jobseeker) }

  after { sign_out(jobseeker) }

  describe "POST #submit_category" do
    context "when the form is valid" do
      it "redirects to the new qualification page for the category" do
        post submit_category_jobseekers_profile_qualifications_path,
             params: { jobseekers_qualifications_category_form: { category: "undergraduate" } }

        expect(response).to redirect_to(new_jobseekers_profile_qualification_path(category: "undergraduate"))
      end
    end

    context "when the form is invalid" do
      it "renders the category selection page with an unprocessable content status" do
        post submit_category_jobseekers_profile_qualifications_path,
             params: { jobseekers_qualifications_category_form: { category: "" } }

        expect(response).to render_template(:select_category)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH #update" do
    let!(:qualification) do
      create(:qualification,
             category: "undergraduate",
             institution: "Life University",
             job_application: nil,
             jobseeker_profile: profile)
    end

    let(:params) do
      {
        jobseekers_qualifications_degree_form: {
          category: "undergraduate",
          finished_studying: "true",
          grade: "Honours",
          institution: institution,
          subject: "Biology",
          year: "2020",
        },
      }
    end

    context "when the form is valid" do
      let(:institution) { "University of Life" }

      it "updates the qualification and redirects to the review page" do
        expect { patch jobseekers_profile_qualification_path(qualification), params: params }
          .to change { qualification.reload.institution }.from("Life University").to("University of Life")

        expect(response).to redirect_to(review_jobseekers_profile_qualifications_path)
      end
    end

    context "when the form is invalid" do
      let(:institution) { "" }

      it "does not update the qualification and renders the edit page with an unprocessable content status" do
        expect { patch jobseekers_profile_qualification_path(qualification), params: params }
          .to(not_change { qualification.reload.institution })

        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
