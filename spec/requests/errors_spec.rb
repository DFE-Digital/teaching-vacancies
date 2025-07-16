require "rails_helper"

RSpec.describe "Errors" do
  describe "GET #not_found" do
    it "returns not found" do
      get not_found_path
      expect(response).to have_http_status(:not_found)
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

  describe "GET #unauthorised" do
    context "when requesting HTML format" do
      it "renders the unauthorised page with 401 status" do
        get unauthorised_path
        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to include("text/html")
        expect(response.body).to include("We were unable to authorise your request.")
      end
    end

    context "when requesting JSON format" do
      it "renders a JSON error with 401 status" do
        get unauthorised_path, headers: { "ACCEPT" => "application/json" }
        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to include("application/json")
        expect(response.parsed_body).to eq({ "error" => "Not authorised" })
      end
    end

    context "when requesting an unsupported format" do
      it "renders with 401 status and empty body" do
        get unauthorised_path, headers: { "ACCEPT" => "application/xml" }
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to be_blank
      end
    end
  end
end
