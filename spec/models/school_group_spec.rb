require "rails_helper"

RSpec.describe SchoolGroup do
  it { is_expected.to have_many(:school_group_memberships) }
  it { is_expected.to have_many(:schools) }

  it { expect(subject.attributes).to include("gias_data") }
  it { expect(described_class.columns_hash["gias_data"].type).to eq(:json) }

  describe "#faith_school?" do
    subject(:school_group) { create(:school_group, schools:) }

    context "when any of the group schools is a faith school" do
      let(:schools) { [create(:school, religious_character: "None"), create(:school, :catholic)] }

      it { is_expected.to be_faith_school }
    end

    context "when none of the group schools is a faith school" do
      let(:schools) { [create(:school, religious_character: "None"), create(:school, religious_character: "Does not apply")] }

      it { is_expected.not_to be_faith_school }
    end

    context "when the group has no schools" do
      let(:schools) { [] }

      it { is_expected.not_to be_faith_school }
    end
  end
end
