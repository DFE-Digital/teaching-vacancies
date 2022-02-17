require "rails_helper"

RSpec.describe "Errors" do
  describe "GET #not_found" do
    it "returns not found" do
      get not_found_path
      expect(response).to have_http_status(:not_found)
    end

    it "does not trigger an api_queried event" do
      expect { get not_found_path }.not_to have_triggered_event(:api_queried)
    end
  end

  describe "GET #unprocessable_entity" do
    it "returns unprocessable_entity" do
      get unprocessable_entity_path
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET #internal_server_error" do
    it "returns internal_server_error" do
      get internal_server_error_path
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "GET #invalid_recaptcha" do
    it "sends the error to Sentry" do
      expect(Sentry).to receive(:capture_exception).with("Invalid recaptcha")

      get invalid_recaptcha_path, params: { form_name: "this form" }
    end

    it "returns unauthorised" do
      get invalid_recaptcha_path
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
