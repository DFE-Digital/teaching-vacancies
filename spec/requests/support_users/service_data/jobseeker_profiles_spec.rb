require "rails_helper"

RSpec.describe "Accessign the service data jobseeker profiles" do
  context "when signed in as a support user" do
    let(:support_user) { create(:support_user, email: "test@example.com") }
    let(:personal_details) { create(:personal_details, first_name: "John", last_name: "Smith") }
    let!(:jobseeker_profile) { create(:jobseeker_profile, :completed, personal_details: personal_details) }

    before do
      sign_in(support_user, scope: :support_user)
    end

    it "can access the service data jobseeker profiles list" do
      get support_users_service_data_jobseeker_profiles_path

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expect(response.body).to include("Jobseeker Profiles")
      expect(response.body).to include("John Smith")
    end

    it "can access a Jobseeker Profile information in the profiles list" do
      get support_users_service_data_jobseeker_profile_path(jobseeker_profile)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
      expect(response.body).to include("John Smith")
    end

    it "gets their access to a Jobseeker Profile logged" do
      allow(Rails.logger).to receive(:info).with(anything)
      expect(Rails.logger).to receive(:info)
        .with("[Service Data] #{support_user.email} accessed Profile ID #{jobseeker_profile.id} at #{Time.current}")

      get support_users_service_data_jobseeker_profile_path(jobseeker_profile)
    end
  end

  context "when not signed in" do
    it "cannot access the service data jobseeker profiles list" do
      get support_users_service_data_jobseeker_profiles_path

      expect(response).to redirect_to(new_support_user_session_path(redirected: true))
    end
  end

  context "when signed in as a publisher" do
    let(:publisher) { create(:publisher) }

    before do
      sign_in(publisher, scope: :publisher)
    end

    it "cannot access the service data jobseeker profiles list" do
      get support_users_service_data_jobseeker_profiles_path

      expect(response).to redirect_to(new_support_user_session_path(redirected: true))
    end
  end

  context "when signed in as a jobseeker" do
    let(:jobseeker) { create(:jobseeker) }

    before do
      sign_in(jobseeker, scope: :jobseeker)
    end

    it "cannot access the service data jobseeker profiles list" do
      get support_users_service_data_jobseeker_profiles_path

      expect(response).to redirect_to(new_support_user_session_path(redirected: true))
    end
  end
end
