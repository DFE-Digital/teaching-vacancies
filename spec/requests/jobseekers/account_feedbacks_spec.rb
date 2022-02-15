require "rails_helper"

RSpec.describe "Account feedback" do
  let(:jobseeker) { create(:jobseeker) }

  describe "GET #new" do
    context "when logged out" do
      it "redirects to the sign in page" do
        expect(get(new_jobseekers_account_feedback_path)).to redirect_to(new_jobseeker_session_path(redirected: true))
      end
    end
  end
end
