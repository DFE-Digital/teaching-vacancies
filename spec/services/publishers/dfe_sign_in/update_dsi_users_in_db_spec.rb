require "rails_helper"

RSpec.describe Publishers::DfeSignIn::UpdateUsersInDb do
  let(:test_file_1_path) { Rails.root.join("spec/fixtures/dfe_sign_in_service_users_response_page_1.json") }
  let(:test_file_2_path) { Rails.root.join("spec/fixtures/dfe_sign_in_service_users_response_page_2.json") }
  let(:update_dfe_sign_in_users) { described_class.new }

  describe "#convert_to_user" do
    it "updates the users database with correct emails and URNs/UIDs" do
      school = create(:school, urn: "111111")
      local_authority = create(:school_group, local_authority_code: "813")
      create(:school, urn: "333333")
      create(:school, urn: "555555")
      create(:school_group, uid: "222222")
      create(:school_group, uid: "444444")

      expect {
        JSON.parse(File.read(test_file_1_path)).fetch("users").each { |u| update_dfe_sign_in_users.convert_to_user(u) }
        JSON.parse(File.read(test_file_2_path)).fetch("users").each { |u| update_dfe_sign_in_users.convert_to_user(u) }
      }.to change { Publisher.all.size }.by(3)

      user_with_one_school = Publisher.find_by!(email: "foo@education.gov.uk")
      expect(user_with_one_school.given_name).to eq("Roger")
      expect(user_with_one_school.family_name).to eq("Johnson")
      expect(user_with_one_school.organisations.first).to eq(school)

      user_with_multiple_orgs = Publisher.find_by!(email: "bar@education.gov.uk")
      expect(user_with_multiple_orgs.given_name).to eq("Alice")
      expect(user_with_multiple_orgs.family_name).to eq("Robertson")
      expect(user_with_multiple_orgs.organisations.count).to be(4)

      local_authority_user = Publisher.find_by!(email: "baz@education.gov.uk")
      expect(local_authority_user.given_name).to eq("Barry")
      expect(local_authority_user.family_name).to eq("Scott")
      expect(local_authority_user.organisations.first).to eq(local_authority)
    end
  end
end
