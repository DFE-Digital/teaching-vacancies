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
        expect(response).not_to have_http_status(:found)
      end
    end
  end

  context "when authentication fallback is not enabled" do
    let(:authentication_fallback_enabled?) { false }

    context "when trying to sign in via DfE Sign In" do
      before { get new_publisher_session_path }

      it "does not redirect" do
        expect(response).not_to have_http_status(:found)
      end
    end

    context "when trying to sign in via fallback authentication method" do
      before { get new_publishers_login_key_path }

      it "redirects to the DfE Sign In authentication domain" do
        expect(response).to redirect_to(new_publisher_session_path)
      end
    end
  end

  context "when organisation profile is incomplete" do
    let(:authentication_fallback_enabled?) { false }
    let(:publisher) { create(:publisher) }
    let(:organisation) { build(:school) }

    before do
      allow(organisation).to receive(:profile_complete?).and_return(false)
      allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
      allow_any_instance_of(Publishers::VacanciesController).to receive(:signing_in?).and_return(true)

      sign_in(publisher, scope: :publisher)
      get organisation_jobs_with_type_path
    end

    it "redirects to complete your profile reminder" do
      follow_redirect!
      expect(response.body).to include("Complete your school profile")
    end
  end
end
