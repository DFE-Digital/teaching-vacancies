require "rails_helper"

RSpec.describe "Jobseeker profile employments" do
  let(:jobseeker) { create(:jobseeker) }
  let(:profile) { create(:jobseeker_profile, jobseeker:) }
  let(:organisation) { "Arsenal" }
  let(:job_title) { "Number 9" }
  let(:started_on_month) { "01" }
  let(:started_on_year) { "2001" }
  let(:current_role) { "no" }
  let(:ended_on_month) { "01" }
  let(:ended_on_year) { "2002" }
  let(:main_duties) { "Scoring goals" }
  let(:days) { { "started_on(3i)": "1", "ended_on(3i)": "1" } }
  let(:reason_for_leaving) { "relocating" }
  let(:params) do
    {
      jobseekers_profile_employment_form: {
        organisation: organisation,
        job_title: job_title,
        "started_on(2i)": started_on_month,
        "started_on(1i)": started_on_year,
        current_role: current_role,
        "ended_on(2i)": ended_on_month,
        "ended_on(1i)": ended_on_year,
        main_duties: main_duties,
        reason_for_leaving: reason_for_leaving,
      }.merge(days),
    }
  end

  before { sign_in(jobseeker, scope: :jobseeker) }

  describe "GET #new" do
    it "renders the new page" do
      expect(get(new_jobseekers_profile_work_history_path)).to render_template(:new)
    end
  end

  describe "GET #edit" do
    let(:profile) { create(:jobseeker_profile) }
    let!(:employment) { create(:employment, :jobseeker_profile_employment, jobseeker_profile_id: profile.id) }

    it "renders the edit page" do
      expect(get(edit_jobseekers_profile_work_history_path(employment))).to render_template(:edit)
    end
  end

  describe "POST #create" do
    context "when the form is valid" do
      it "creates the employment and redirects to the review page" do
        expect { post jobseekers_profile_work_history_index_path, params: params }
          .to change { Employment.count }.by(1)

        expect(response).to redirect_to(review_jobseekers_profile_work_history_index_path)
      end
    end

    context "when the form is invalid" do
      let(:organisation) { nil }

      it "does not create the employment and renders the new page" do
        expect { post jobseekers_profile_work_history_index_path, params: params }
          .to(not_change { Employment.count })

        expect(response).to render_template(:new)
      end
    end
  end

  describe "PATCH #update" do
    let!(:employment) { create(:employment, :jobseeker_profile_employment, organisation: previous_organisation, jobseeker_profile_id: profile.id) }
    let(:previous_organisation) { "Test organisation" }
    let(:organisation) { "Arsenal" }

    context "when the form is valid" do
      before { allow_any_instance_of(Jobseekers::Profile::EmploymentForm).to receive(:valid?).and_return(true) }

      it "updates the employment and redirects to the review page" do
        expect { patch jobseekers_profile_work_history_path(employment), params: params }
          .to change { employment.reload.organisation }.from(previous_organisation).to(organisation)

        expect(response).to redirect_to(review_jobseekers_profile_work_history_index_path)
      end
    end

    context "when the form is invalid" do
      let(:organisation) { nil }

      it "does not update the employment and renders the edit page" do
        expect { patch jobseekers_profile_work_history_path(employment), params: params }
          .to(not_change { employment.reload.organisation })

        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:employment) { create(:employment, :jobseeker_profile_employment, jobseeker_profile_id: profile.id) }

    it "destroys the employment and redirects to the review page" do
      expect { delete jobseekers_profile_work_history_path(employment) }
        .to change { Employment.count }.by(-1)

      expect(response).to redirect_to(review_jobseekers_profile_work_history_index_path)
    end
  end
end
