require "rails_helper"

RSpec.describe Publishers::SignIn::Dfe::SessionsController, type: :controller do
  describe "#new" do
    before do
      allow(AuthenticationFallback).to receive(:enabled?).and_return(false)
    end

    it "redirects to Dfe" do
      get :new
      expect(response).to redirect_to("/auth/dfe") # From here we trust Omniauth
    end
  end

  describe "#destroy" do
    let(:publisher_session_contents) do
      {
        publisher_oid: "foo",
        organisation_urn: "foo",
        organisation_uid: "foo",
        organisation_la_code: "foo",
        publisher_multiple_organisations: "foo",
        publisher_id_token: "foo",
      }.stringify_keys
    end
    let(:unrelated_session_contents) { { keep_me: { foo: "bar" } }.stringify_keys }

    before do
      session.merge!(publisher_session_contents)
      session.merge!(unrelated_session_contents)
    end

    it "logs the publisher out but keeps the rest of the session intact" do
      get :destroy

      expect(session).not_to include(*publisher_session_contents.keys)
      expect(session).to include(*unrelated_session_contents.keys)
    end
  end
end
