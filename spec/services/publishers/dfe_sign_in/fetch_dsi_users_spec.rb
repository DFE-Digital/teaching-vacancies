require "rails_helper"

RSpec.describe Publishers::DfeSignIn::FetchDSIUsers do
  let(:test_file_empty_users_path) { Rails.root.join("spec/fixtures/dfe_sign_in_service_users_empty_response.json") }
  let(:dsi_users) { described_class.new.dsi_users.to_a }

  describe "#dsi_users" do
    it "raises an error when it finds no users in the response" do
      stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users?page=1&pageSize=#{DfeSignIn::API::USERS_PAGE_SIZE}")
          .to_return(
            body: File.read(test_file_empty_users_path),
          )
      expect { dsi_users }.to raise_error("failed request")
    end

    it "raises an error when the response is empty" do
      stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users?page=1&pageSize=#{DfeSignIn::API::USERS_PAGE_SIZE}")
          .to_return(
            body: "{}",
          )
      expect { dsi_users }.to raise_error("failed request")
    end
  end
end
