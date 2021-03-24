require "rails_helper"

RSpec.describe Jobseekers::SessionsController do
  context "unrelated session contents" do
    let(:unrelated_session_contents) { { keep_me: { foo: "bar" } }.stringify_keys }

    let(:credentials) { { email: "test@example.com", password: "password" } }
    let!(:jobseeker) { Jobseeker.create(credentials) }

    before do
      # Required to test Devise controller independently of routing
      @request.env["devise.mapping"] = Devise.mappings[:jobseeker]

      jobseeker.confirm

      session.merge!(unrelated_session_contents)
    end

    describe "#create" do
      it "does not clear unrelated session contents" do
        post :create, params: { jobseeker: credentials }

        expect(session).to include(*unrelated_session_contents.keys)
      end
    end

    describe "#destroy" do
      before do
        sign_in jobseeker
      end

      it "does not clear unrelated session contents" do
        delete :destroy

        expect(session).to include(*unrelated_session_contents.keys)
      end
    end
  end
end
