require "rails_helper"
require "dfe_sign_in/api/request"
require "dfe_sign_in/api/response"

RSpec.describe DfeSignIn::API::Response do
  subject(:response) { described_class.new(request) }

  let(:api_response) { JSON.parse(response_file) }
  let(:request) { instance_double(DfeSignIn::API::Request, perform: api_response) }

  describe "#number_of_pages" do
    it "returns the number of pages from the API response" do
      expect(response.number_of_pages).to eq(2)
    end

    context "when the API response has no number of pages" do
      before { allow(api_response).to receive(:[]).with("numberOfPages").and_return(nil) }

      context "when the response has a message" do
        before { allow(api_response).to receive(:[]).with("message").and_return("no results found") }

        it "raises an error with the message" do
          expect { response.number_of_pages }.to raise_error("no results found")
        end
      end

      context "when the response has no message" do
        before { allow(api_response).to receive(:[]).with("message").and_return(nil) }

        it "raises an error with a default message" do
          expect { response.number_of_pages }.to raise_error("failed request")
        end
      end
    end
  end

  describe "#users" do
    before do
      allow(api_response).to receive(:[]).with("message").and_call_original
      allow(api_response).to receive(:[]).with("users").and_call_original
    end

    it "returns the users from the API response" do
      expect(response.users).to eq(api_response["users"])
    end

    context "when there are no users in the response" do
      before { allow(api_response).to receive(:[]).with("users").and_return([]) }

      it "raises an error" do
        expect { response.users }.to raise_error(DfeSignIn::API::Response::NilUsersError)
      end
    end

    context "when the first user in the response is empty" do
      before { allow(api_response).to receive(:[]).with("users").and_return([{}]) }

      it "raises an error" do
        expect { response.users }.to raise_error(DfeSignIn::API::Response::NilUsersError)
      end
    end
  end

  def response_file
    File.read(Rails.root.join(
                "spec",
                "fixtures",
                "dfe_sign_in_service_users_response_page_1.json",
              ))
  end
end
