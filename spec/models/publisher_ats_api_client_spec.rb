require "rails_helper"

RSpec.describe PublisherAtsApiClient do
  describe "#generate_api_key" do
    subject(:generate_api_key) { api_client.generate_api_key }

    let(:api_client) { build(:publisher_ats_api_client, api_key: nil) }

    it "generates a new API key" do
      expect { generate_api_key }.to change(api_client, :api_key).from(nil).to(be_present)
    end

    it "generates a 40-character hex API key" do
      generate_api_key
      expect(api_client.api_key).to match(/\A[a-f0-9]{40}\z/)
    end
  end

  describe "#rotate_api_key!" do
    subject(:rotate_api_key) { api_client.rotate_api_key! }

    let(:api_client) { create(:publisher_ats_api_client, last_rotated_at: 1.day.ago) }
    let(:old_key) { api_client.api_key }

    it "updates the API key with a new value" do
      expect { rotate_api_key }.to change(api_client, :api_key).from(old_key)
    end

    it "updates the last_rotated_at timestamp" do
      expect { rotate_api_key }.to change(api_client, :last_rotated_at)
    end

    it "sets a 40-character hex API key" do
      rotate_api_key
      expect(api_client.api_key).to match(/\A[a-f0-9]{40}\z/)
    end
  end

  describe "#unique_organisations_count" do
    subject(:unique_organisations_count) { api_client.unique_organisations_count }

    let(:api_client) { create(:publisher_ats_api_client) }
    let(:first_organisation) { create(:school) }
    let(:second_organisation) { create(:trust) }
    let(:third_organisation) { create(:school) }

    before do
      create(:vacancy, :external, publisher_ats_api_client: api_client, organisations: [first_organisation])
      create(:vacancy, :external, publisher_ats_api_client: api_client, organisations: [first_organisation])
      create(:vacancy, :external, publisher_ats_api_client: api_client, organisations: [first_organisation, third_organisation])
      create(:vacancy, :external, publisher_ats_api_client: api_client, organisations: [second_organisation])
    end

    it "returns the count of unique organisations associated with the vacancies" do
      expect(unique_organisations_count).to eq(3)
    end
  end
end
