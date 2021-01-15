require "rails_helper"

RSpec.describe "DfE Sign-in", type: :request do
  context "when a request comes in without proper OIDC params" do
    it "routes the request back to DSI" do
      get auth_dfe_callback_path

      expect(response).to redirect_to("/auth/failure?message=csrf_detected&strategy=dfe")
      follow_redirect!
      expect(response).to redirect_to("/dfe/sessions/new")
    end
  end
end
