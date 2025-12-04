require "rails_helper"

RSpec.describe Organisation do
  it { is_expected.to have_many(:publishers) }
  it { is_expected.to have_many(:organisation_publishers) }
  it { is_expected.to have_many(:vacancies) }
  it { is_expected.to have_many(:organisation_vacancies) }

  describe "email validation" do
    it "doesn't validate existing email" do
      org = described_class.new(email: "invalidaaddress")
      org.save!(validate: false)

      expect(org).to be_valid
    end

    it "validates new email" do
      org = create(:school)
      org.email = "invalidaaddress"

      expect(org).not_to be_valid
    end
  end

  describe "#all_vacancies" do
    context "when the organisation is a school" do
      let!(:school1) { create(:school) }
      let!(:school2) { create(:school) }
      let(:vacancy) { create(:vacancy, organisations: [school1]) }

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
      let!(:trust) { create(:trust, schools: [school1]) }
      let(:vacancy1) { create(:vacancy, organisations: [school1]) }
      let(:vacancy2) { create(:vacancy, organisations: [trust]) }
      let(:vacancy3) { create(:vacancy, organisations: [school2]) }

      it "returns all vacancies from the trust and the schools of the trust" do
        expect(trust.all_vacancies).to include(vacancy1, vacancy2)
        expect(trust.all_vacancies).not_to include(vacancy3)
      end
    end

    context "when the organisation is a local authority" do
      let!(:local_authority) { create(:local_authority, local_authority_code: "111", schools: [school3]) }
      let(:school1) { create(:school, urn: "123") }
      let(:school2) { create(:school, urn: "654") }
      let(:school3) { create(:school) }
      let(:school4) { create(:school) }
      let!(:vacancy1) { create(:vacancy, organisations: [school1]) }
      let!(:vacancy2) { create(:vacancy, organisations: [school2]) }
      let!(:vacancy3) { create(:vacancy, organisations: [school3]) }
      let!(:vacancy4) { create(:vacancy, organisations: [school4]) }
      let(:local_authorities_extra_schools) { { 111 => [123] } }

      before { allow(Rails.configuration).to receive(:local_authorities_extra_schools).and_return(local_authorities_extra_schools) }

      it "returns all vacancies from the schools inside and outside of the local authority" do
        expect(local_authority.all_vacancies).to include(vacancy1, vacancy3)
        expect(local_authority.all_vacancies).not_to include(vacancy2)
        expect(local_authority.all_vacancies).not_to include(vacancy4)
      end
    end
  end

  describe "#with_live_vacancies" do
    subject { described_class.with_live_vacancies }

    before do
      create(:school, name: "Empty", school_groups: [empty_group])
      sg = create(:trust, name: "Trust with vacancy")
      active = create(:school, name: "Active", school_groups: [active_group])
      create(:vacancy, organisations: [active])
      create(:vacancy, organisations: [sg])
    end

    context "when the organisation is a trust" do
      let(:empty_group) { create(:trust, name: "Empty Trust") }
      let(:active_group) { create(:trust, name: "Trust") }

      it "returns school, trust (due to school being part of the trust) and trust with vacancy" do
        expect(subject.map(&:name)).to contain_exactly("Active", "Trust", "Trust with vacancy")
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

  describe "type predicates" do
    context "for a school" do
      subject { build_stubbed(:school) }

      it { is_expected.to be_school }
      it { is_expected.not_to be_school_group }
      it { is_expected.not_to be_trust }
      it { is_expected.not_to be_local_authority }
    end

    context "for a trust" do
      subject { build_stubbed(:trust) }

      it { is_expected.not_to be_school }
      it { is_expected.to be_school_group }
      it { is_expected.to be_trust }
      it { is_expected.not_to be_local_authority }
    end

    context "for a local authority" do
      subject { build_stubbed(:local_authority) }

      it { is_expected.not_to be_school }
      it { is_expected.to be_school_group }
      it { is_expected.not_to be_trust }
      it { is_expected.to be_local_authority }
    end
  end

  describe "#refresh_gias_data_hash" do
    subject { create(:school, gias_data: { foo: "bar" }, gias_data_hash: hash) }

    let(:sha_256_hexdigest_for_foo_bar) { "e1d4f8c43b7b0393ffc10bf5959d52154d99abc9cb4b19f2f6b032d0b991e21e" }

    context "when the gias_data has changed" do
      let(:hash) { "Foo" }

      it "recomputes the hash" do
        expect { subject.refresh_gias_data_hash }
          .to change { subject.gias_data_hash }
          .from("Foo")
          .to(sha_256_hexdigest_for_foo_bar)
      end
    end

    context "when the gias_data has not changed" do
      let(:hash) { sha_256_hexdigest_for_foo_bar }

      it "does not change the hash" do
        subject.refresh_gias_data_hash
        expect(subject.gias_data_hash_previously_was).to be_nil
      end
    end
  end

  describe ".visible_to_jobseekers" do
    let!(:publisher) { create(:publisher, organisations: [trust, open_school, closed_school, out_of_scope_school1, out_of_scope_school2, out_of_scope_school3, out_of_scope_school4, out_of_scope_school5, out_of_scope_school6, out_of_scope_school7]) }
    let!(:open_school) { create(:school, establishment_status: "Open", detailed_school_type: "Primary school") }
    let!(:closed_school) { create(:school, establishment_status: "Closed", detailed_school_type: "Secondary school") }
    let(:trust) { Organisation.create(type: "SchoolGroup", name: "Trust", uid: "1") }
    let!(:out_of_scope_school1) { create(:school, establishment_status: "Open", detailed_school_type: "Further education") }
    let!(:out_of_scope_school2) { create(:school, establishment_status: "Open", detailed_school_type: "Other independent school") }
    let!(:out_of_scope_school3) { create(:school, establishment_status: "Open", detailed_school_type: "Miscellaneous") }
    let!(:out_of_scope_school4) { create(:school, establishment_status: "Open", detailed_school_type: "Special post 16 institution") }
    let!(:out_of_scope_school5) { create(:school, establishment_status: "Open", detailed_school_type: "Other independent special school") }
    let!(:out_of_scope_school6) { create(:school, establishment_status: "Open", detailed_school_type: "Higher education institutions") }
    let!(:out_of_scope_school7) { create(:school, establishment_status: "Open", detailed_school_type: "Welsh establishment") }

    it "returns open schools that are not out of scope" do
      expect(Organisation.visible_to_jobseekers).to include(open_school)
    end

    it "excludes closed schools" do
      expect(Organisation.visible_to_jobseekers).not_to include(closed_school)
    end

    it "includes trusts" do
      expect(Organisation.visible_to_jobseekers).to include(trust)
    end

    it "excludes schools that are out of scope" do
      expect(Organisation.visible_to_jobseekers).not_to include(out_of_scope_school1, out_of_scope_school2, out_of_scope_school3, out_of_scope_school4, out_of_scope_school5, out_of_scope_school6, out_of_scope_school7)
    end
  end

  describe "#live_group_vacancies" do
    it "returns a blank relation" do
      expect(described_class.new.live_group_vacancies).to be_empty
    end
  end

  describe "#should_generate_new_friendly_id?" do
    subject { create(:school) }

    context "when name changes" do
      it "creates a new slug" do
        old_slug = subject.slug
        expect { subject.update(name: "new name school") }.to change(subject, :slug).from(old_slug).to("new-name-school")
      end
    end

    context "when another field changes" do
      it "does not create a new slug" do
        expect { subject.update(description: "Oh it is terrific") }.not_to change(subject, :slug)
      end
    end
  end
end
