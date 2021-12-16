require "rails_helper"
require "update_dsi_users_in_db"

RSpec.describe UpdateDsiUsersInDb do
  let(:test_file_1_path) { Rails.root.join("spec/fixtures/dfe_sign_in_service_users_response_page_1.json") }
  let(:test_file_2_path) { Rails.root.join("spec/fixtures/dfe_sign_in_service_users_response_page_2.json") }
  let(:test_file_empty_users_path) { Rails.root.join("spec/fixtures/dfe_sign_in_service_users_empty_response.json") }
  let(:update_dfe_sign_in_users) { described_class.new }

  describe "#run!" do
    before do
      allow(described_class).to receive(:new).and_return(update_dfe_sign_in_users)
    end

    it "updates the users database with correct emails and URNs/UIDs" do
      allow(update_dfe_sign_in_users).to receive(:number_of_pages).and_return(2)

      [test_file_1_path, test_file_2_path].each_with_index do |file_path, index|
        stub_request(:get, "#{DFE_SIGN_IN_URL}/users?page=#{index + 1}&pageSize=#{DFESignIn::API::USERS_PAGE_SIZE}")
          .to_return(
            body: File.read(file_path),
          )
      end

      school = create(:school, urn: "111111")
      local_authority = create(:school_group, local_authority_code: "813")
      create(:school, urn: "333333")
      create(:school, urn: "555555")
      create(:school_group, uid: "222222")
      create(:school_group, uid: "444444")

      expect { update_dfe_sign_in_users.run! }.to change { Publisher.all.size }.by(3)

      user_with_one_school = Publisher.find_by(email: "foo@example.com")
      expect(user_with_one_school.given_name).to eq("Roger")
      expect(user_with_one_school.family_name).to eq("Johnson")
      expect(user_with_one_school.organisations.first).to eq(school)

      user_with_multiple_orgs = Publisher.find_by(email: "bar@example.com")
      expect(user_with_multiple_orgs.given_name).to eq("Alice")
      expect(user_with_multiple_orgs.family_name).to eq("Robertson")
      expect(user_with_multiple_orgs.organisations.count).to be(4)

      local_authority_user = Publisher.find_by(email: "baz@example.com")
      expect(local_authority_user.given_name).to eq("Barry")
      expect(local_authority_user.family_name).to eq("Scott")
      expect(local_authority_user.organisations.first).to eq(local_authority)
    end

    it "raises an error when it finds no users in the response" do
      allow(update_dfe_sign_in_users).to receive(:number_of_pages).and_return(1)

      stub_request(:get, "#{DFE_SIGN_IN_URL}/users?page=1&pageSize=#{DFESignIn::API::USERS_PAGE_SIZE}")
          .to_return(
            body: File.read(test_file_empty_users_path),
          )
      expect { update_dfe_sign_in_users.run! }.to raise_error("failed request")

      stub_request(:get, "#{DFE_SIGN_IN_URL}/users?page=1&pageSize=#{DFESignIn::API::USERS_PAGE_SIZE}")
          .to_return(
            body: "{}",
          )
      expect { update_dfe_sign_in_users.run! }.to raise_error("failed request")
    end
  end
end
