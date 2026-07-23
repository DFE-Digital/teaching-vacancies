require "rails_helper"

RSpec.describe "DfE Sign In omniauth callbacks" do
  let(:sentry_scope) { instance_double(Sentry::Scope, set_context: nil) }

  before do
    allow(AuthenticationFallback).to receive(:enabled?).and_return(false)
    allow(Sentry).to receive(:configure_scope).and_yield(sentry_scope)
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  describe "GET /auth/dfe/callback" do
    context "with a complete auth hash" do
      before do
        create(:school, urn: "110627")
        stub_accepted_terms_and_conditions
        stub_publisher_authentication_step
        stub_publisher_authorisation_step
        stub_sign_in_with_multiple_organisations
      end

      it "attaches the DSI auth data to the Sentry scope and signs the publisher in" do
        get "/auth/dfe/callback"

        expect(sentry_scope).to have_received(:set_context).with(
          "DSI auth data",
          {
            dsi_user_id: "161d1f6a-44f1-4a1a-940d-d1088c439da7",
            organisation: hash_including("id" => "939eac36-0777-48c2-9c2c-b87c948a9ee0", "urn" => "110627"),
            auth_hash_shape: hash_including(
              "uid" => "String",
              "info" => { "email" => "String" },
              "extra" => {
                "raw_info" => {
                  "organisation" => hash_including("id" => "String", "urn" => "String", "category" => { "id" => "String", "name" => "String" }),
                },
              },
            ),
          },
        )
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the auth hash has no organisation" do
      before do
        OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
          provider: "dfe",
          uid: "161d1f6a-44f1-4a1a-940d-d1088c439da7",
          info: { email: "an-email@example.com" },
          extra: { raw_info: {} },
        )
      end

      it "renders the pending approval page" do
        get "/auth/dfe/callback"

        expect(response.body).to include("Your account is waiting for approval")
      end
    end

    context "when the auth hash organisation has no id" do
      before do
        OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
          provider: "dfe",
          uid: "161d1f6a-44f1-4a1a-940d-d1088c439da7",
          info: { email: "an-email@example.com" },
          extra: {
            raw_info: {
              organisation: { urn: "110627", name: "FooBar organisation" },
            },
          },
        )
      end

      it "renders the pending approval page and attaches the DSI auth data to the Sentry scope" do
        get "/auth/dfe/callback"

        expect(response.body).to include("Your account is waiting for approval")
        expect(sentry_scope).to have_received(:set_context).with(
          "DSI auth data",
          hash_including(
            organisation: hash_including("urn" => "110627"),
            auth_hash_shape: hash_including(
              "extra" => { "raw_info" => { "organisation" => { "urn" => "String", "name" => "String" } } },
            ),
          ),
        )
      end
    end
  end

  describe "OmniauthCallbacksController#set_sentry_auth_context" do
    it "does not set any context when there is no auth hash" do
      controller = OmniauthCallbacksController.new
      allow(controller).to receive(:auth_hash).and_return(nil)

      controller.send(:set_sentry_auth_context)

      expect(Sentry).not_to have_received(:configure_scope)
    end
  end
end
