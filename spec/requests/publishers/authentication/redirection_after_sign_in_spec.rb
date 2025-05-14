require "rails_helper"

RSpec.describe "Publishers redirection" do
  let(:organisation) { create(:school, :with_image) }
  let(:publisher) { create(:publisher) }
  let(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation]) }

  before do
    allow(AuthenticationFallback).to receive(:enabled?).and_return(false)

    stub_accepted_terms_and_conditions
    OmniAuth.config.test_mode = true
    stub_publisher_authentication_step(organisation_id: organisation.id, school_urn: organisation.urn)
    stub_publisher_authorisation_step(organisation_id: organisation.id)
  end

  after do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  context "when authentication successful" do
    it "redirects to requested page" do
      get organisation_job_path(vacancy)
      expect(response).to redirect_to(new_publisher_session_path(redirected: true))

      get auth_dfe_callback_path
      expect(response).to redirect_to(organisation_job_path(vacancy))
    end

    it "redirects to publisher root page when coming from unprotected page" do
      get auth_dfe_callback_path
      expect(response).to redirect_to(publisher_root_path)
    end

    context "when the organisation's profile is incomplete" do
      let(:organisation) { create(:school, :with_image, email: nil) }

      it "redirects to the interstitial profile completion reminder page" do
        get auth_dfe_callback_path
        follow_redirect! # needed to trigger the before_action of publisher_root_path
        expect(response).to redirect_to(publishers_organisation_profile_incomplete_path(organisation))
      end
    end
  end

  context "when authentication failed" do
    context "when record not found" do
      before do
        stub_publisher_authentication_step(organisation_id: "fake", school_urn: "fakeurn")
      end

      it "returns not found" do
        get auth_dfe_path
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when authorisation failed" do
      before do
        stub_publisher_authentication_step(email: "another_email@example.com")
        stub_publisher_authorisation_step_with_not_found
      end

      it "renders not_authorised template" do
        get auth_dfe_callback_path
        expect(response).to render_template(:not_authorised)
      end
    end
  end
end
