require "rails_helper"

RSpec.describe "DfE Sign-in", type: :request do
  context "when DfE Sign-in respond with an OIDC payload for authentication purposes" do
    context "when that payload is unauthorised" do
      it "redirects the user to the DfE sign-in new session page" do
        params = {
          'code': "a-long-secret",
          'session_state': "123.456"
        }

        get auth_dfe_callback_path, params: params

        expect(response.status).to eq(302)
        expect(response.body).to eq("Redirecting to /dfe/sessions/new...")
      end
    end
  end

  context "when a user is linked back to our service with a redirect" do
    it "routes the request back to the new sign-in page" do
      request = get auth_dfe_callback_path
      expect(request).to redirect_to(new_dfe_path)
    end
  end
end
