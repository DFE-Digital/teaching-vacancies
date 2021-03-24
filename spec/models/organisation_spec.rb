require "rails_helper"

RSpec.describe Organisation do
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

  describe "#schools_outside_local_authority" do
    let(:local_authority) { create(:local_authority, local_authority_code: "111") }
    let!(:school1) { create(:school, urn: "123456") }
    let!(:school2) { create(:school, urn: "654321") }

    before { allow(Rails.configuration).to receive(:local_authorities_extra_schools).and_return(local_authorities_extra_schools) }

    context "when there are schools outside local authority" do
      let(:local_authorities_extra_schools) { { 111 => [123_456, 999_999], 999 => [654_321, 111_111] } }

      it "returns the schools with matching URNs" do
        expect(local_authority.schools_outside_local_authority).to eq [school1]
      end
    end

    context "when there are no schools outside local authority" do
      let(:local_authorities_extra_schools) { nil }

      it "returns an empty collection" do
        expect(local_authority.schools_outside_local_authority).to eq []
      end
    end
  end
end
