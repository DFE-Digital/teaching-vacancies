require "rails_helper"

RSpec.describe "Redirect to correct authentication method" do
  before do
    allow(AuthenticationFallback).to receive(:enabled?).and_return(authentication_fallback_enabled?)
  end

  context "when authentication fallback is enabled" do
    let(:authentication_fallback_enabled?) { true }

    context "when trying to sign in via DfE Sign In" do
      before { get new_publisher_session_path }

      it "redirects to the fallback authentication domain" do
        expect(response).to redirect_to(new_publishers_login_key_path)
      end
    end

    context "when trying to sign in via fallback authentication method" do
      before { get new_publishers_login_key_path }

      it "does not redirect" do
        expect(response.status).not_to eq(302)
      end
    end
  end

  context "when authentication fallback is not enabled" do
    let(:authentication_fallback_enabled?) { false }

    context "when trying to sign in via DfE Sign In" do
      before { get new_publisher_session_path }

      it "does not redirect" do
        expect(response.status).not_to eq(302)
      end
    end

    context "when trying to sign in via fallback authentication method" do
      before { get new_publishers_login_key_path }

      it "redirects to the DfE Sign In authentication domain" do
        expect(response).to redirect_to(new_publisher_session_path)
      end
    end
  end
end
