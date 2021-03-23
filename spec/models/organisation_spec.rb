require "rails_helper"

RSpec.describe Organisation, type: :model do
  it { is_expected.to have_many(:publishers) }
  it { is_expected.to have_many(:organisation_publishers) }
  it { is_expected.to have_many(:vacancies) }
  it { is_expected.to have_many(:organisation_vacancies) }

  describe "#name" do
    context "when the organisation is a local authority" do
      let(:trust) { create(:trust, name: "My Amazing Trust") }

      it "does not append 'local authority' when reading the name" do
        expect(trust.name).to eq("My Amazing Trust")
      end
    end

    context "when the organisation is not a local authority" do
      let(:local_authority) { create(:local_authority, name: "Camden") }

      it "does not append 'local authority' when reading the name" do
        expect(local_authority.name).to eq("Camden local authority")
      end
    end
  end
end
