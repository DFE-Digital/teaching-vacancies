require "rails_helper"

RSpec.describe "Accessing the service data FE colleges without publishers who have accepted the terms and conditions" do
  context "when signed in as a support user" do
    let(:support_user) { create(:support_user, email: "test@example.com") }
    let!(:college_without_publishers) { create(:college, name: "College Without Publishers") }
    let!(:college_with_accepted_publisher) { create(:college, name: "College With Accepted Publisher") }
    let!(:college_with_unaccepted_publisher) { create(:college, name: "College With Unaccepted Publisher") }
    let!(:old_college) { create(:college, name: "Old College") }

    before do
      create(:college, :discarded, name: "Discarded College")
      create(:school, name: "A School")
      create(:publisher, accepted_terms_at: Time.current, organisations: [college_with_accepted_publisher])
      create(:publisher, accepted_terms_at: nil, organisations: [college_with_unaccepted_publisher])
      # update_column bypasses the ActionText `touch: true` callback that would otherwise reset this to now.
      old_college.update_column(:updated_at, 2.weeks.ago)
      sign_in(support_user, scope: :support_user)
    end

    after { sign_out(support_user) }

    it "lists FE colleges updated in the last week with no publisher who has accepted the terms and conditions" do
      get support_users_service_data_fe_colleges_without_publishers_path

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expect(response.body).to include("College Without Publishers")
      expect(response.body).to include("College With Unaccepted Publisher")
      expect(response.body).not_to include("College With Accepted Publisher")
      expect(response.body).not_to include("Discarded College")
      expect(response.body).not_to include("Old College")
      expect(response.body).not_to include("A School")
    end

    context "when every FE college has a publisher who has accepted the terms and conditions" do
      before do
        create(:publisher, accepted_terms_at: Time.current, organisations: [college_without_publishers, college_with_unaccepted_publisher])
      end

      it "shows an empty state" do
        get support_users_service_data_fe_colleges_without_publishers_path

        expect(response.body).to include(I18n.t("support_users.service_data.fe_colleges_without_publishers.index.no_results"))
      end
    end
  end

  context "when not signed in" do
    it "cannot access the page" do
      get support_users_service_data_fe_colleges_without_publishers_path

      expect(response).to redirect_to(new_support_user_session_path(redirected: true))
    end
  end

  context "when signed in as a publisher" do
    let(:publisher) { create(:publisher) }

    before { sign_in(publisher, scope: :publisher) }
    after { sign_out(publisher) }

    it "cannot access the page" do
      get support_users_service_data_fe_colleges_without_publishers_path

      expect(response).to redirect_to(new_support_user_session_path(redirected: true))
    end
  end

  context "when signed in as a jobseeker" do
    let(:jobseeker) { create(:jobseeker) }

    before { sign_in(jobseeker, scope: :jobseeker) }
    after { sign_out(jobseeker) }

    it "cannot access the page" do
      get support_users_service_data_fe_colleges_without_publishers_path

      expect(response).to redirect_to(new_support_user_session_path(redirected: true))
    end
  end
end
