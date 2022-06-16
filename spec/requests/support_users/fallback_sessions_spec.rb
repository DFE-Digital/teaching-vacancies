require "rails_helper"

RSpec.describe "Fallback sign in for support users" do
  let!(:support_user) { create(:support_user, email: "test@example.com") }

  context "when authentication fallback is disabled" do
    before do
      allow(AuthenticationFallback).to receive(:enabled?).and_return(false)
    end

    it "does not allow requesting a fallback sign in link and redirects" do
      post support_users_fallback_sessions_path, params: { support_user: { email: "test@example.com" } }
      expect(response).to redirect_to(new_support_user_session_path)
      expect(ActionMailer::Base.deliveries.count).to be_zero
    end

    it "does not allow using a fallback sign in link and redirects" do
      get support_users_fallback_session_path("some-signed-id")
      expect(response).to redirect_to(new_support_user_session_path)
    end
  end

  context "when authentication fallback is enabled" do
    before do
      allow(AuthenticationFallback).to receive(:enabled?).and_return(true)
    end

    it "allows requesting a fallback sign in link" do
      expect {
        post support_users_fallback_sessions_path,
             params: { support_user: { email: "test@example.com" } }
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    it "shows a not found error with an invalid signed ID" do
      get support_users_fallback_session_path("some-signed-id")
      expect(response.status).to eq(404)
    end
  end
end
