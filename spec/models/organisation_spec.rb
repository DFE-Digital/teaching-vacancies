require "rails_helper"

RSpec.describe Organisation do
  it { is_expected.to have_many(:publishers) }
  it { is_expected.to have_many(:organisation_publishers) }
  it { is_expected.to have_many(:vacancies) }
  it { is_expected.to have_many(:organisation_vacancies) }

  describe "#all_vacancies" do
    context "when the organisation is a school" do
      let!(:school1) { create(:school) }
      let!(:school2) { create(:school) }
      let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: school1 }]) }

      it "returns all vacancies from the school" do
        expect(school1.all_vacancies).to eq [vacancy]
      end

      it "returns no vacancies when there are none" do
        expect(school2.all_vacancies).to be_none
      end
    end

    context "when the organisation is a trust" do
      let!(:school1) { create(:school) }
      let!(:school2) { create(:school) }
      let!(:trust) { create(:trust) }
      let(:vacancy1) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: school1 }]) }
      let(:vacancy2) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: trust }]) }
      let(:vacancy3) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: school2 }]) }

      before { SchoolGroupMembership.create(school_group: trust, school: school1) }

      it "returns all vacancies from the trust and the schools of the trust" do
        expect(trust.all_vacancies).to include(vacancy1, vacancy2)
        expect(trust.all_vacancies).not_to include(vacancy3)
      end
    end

    context "when the organisation is a local authority" do
      let(:local_authority) { create(:local_authority, local_authority_code: "111") }
      let!(:school1) { create(:school, urn: "123") }
      let!(:school2) { create(:school, urn: "654") }
      let!(:school3) { create(:school) }
      let!(:school4) { create(:school) }
      let(:vacancy1) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: school1 }]) }
      let(:vacancy2) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: school2 }]) }
      let(:vacancy3) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: school3 }]) }
      let(:vacancy4) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: school4 }]) }
      let(:local_authorities_extra_schools) { { 111 => [123] } }

      before do
        allow(Rails.configuration).to receive(:local_authorities_extra_schools).and_return(local_authorities_extra_schools)
        SchoolGroupMembership.create(school_group: local_authority, school: school3)
      end

      it "returns all vacancies from the schools inside and outside of the local authority" do
        expect(local_authority.all_vacancies).to include(vacancy1, vacancy3)
        expect(local_authority.all_vacancies).not_to include(vacancy2)
        expect(local_authority.all_vacancies).not_to include(vacancy4)
      end
    end
  end

  describe "#name" do
    context "when the organisation is a local authority" do
      let(:trust) { create(:trust, name: "My Amazing Trust") }

      it "does not append 'local authority' when reading the name" do
        expect(trust.name).to eq("My Amazing Trust")
      end
    end

    context "when the organisation is not a local authority" do
      let(:local_authority) { create(:local_authority, name: "Camden") }

      it "appends 'local authority' when reading the name" do
        expect(local_authority.name).to eq("Camden local authority")
      end
    end
  end

  describe "#schools_outside_local_authority" do
    let(:local_authority) { create(:local_authority, local_authority_code: "111") }
    let!(:school1) { create(:school, urn: "123456") }
    let!(:school2) { create(:school, urn: "654321") }

    before { allow(Rails.configuration).to receive(:local_authorities_extra_schools).and_return(local_authorities_extra_schools) }

    context "when there are schools outside the local authority" do
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
