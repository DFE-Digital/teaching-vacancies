require "rails_helper"

RSpec.describe "Jobseeker job preferences steps" do
  let(:jobseeker) { create(:jobseeker) }
  let(:profile) { create(:jobseeker_profile, :with_location_preferences, jobseeker:) }

  before do
    profile
    sign_in(jobseeker, scope: :jobseeker)
  end

  after { sign_out(jobseeker) }

  describe "GET locations step" do
    it "renders successfully" do
      get jobseekers_job_preferences_step_path(id: :locations)
      expect(response).to have_http_status(:ok)
    end
  end
end
