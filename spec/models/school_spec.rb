require "rails_helper"

RSpec.describe School do
  it { is_expected.to have_many(:school_group_memberships) }
  it { is_expected.to have_many(:school_groups) }

  describe "#school_type" do
    subject { build(:school, school_type: "Academies") }

    it "singularizes any plural school type" do
      expect(subject.school_type).to eq("Academy")
    end
  end

  describe "#religious_character" do
    let(:religious_character) { "Roman Catholic" }
    let(:gias_data) { { "ReligiousCharacter (name)" => religious_character } }

    subject { build(:school, gias_data: gias_data) }

    it "returns religious character" do
      expect(subject.religious_character).to eq "Roman Catholic"
    end

    context "when the school has no religious character" do
      let(:religious_character) { "Does not apply" }

      it "returns nil" do
        expect(subject.religious_character).to eq nil
      end
    end

    context "when the school has no gias_data" do
      let(:gias_data) { nil }

      it "returns nil" do
        expect(subject.religious_character).to eq nil
      end
    end
  end

  describe "#urn" do
    it "must be unique" do
      create(:school, urn: "12345")
      school = build(:school, urn: "12345")
      school.valid?

      expect(school.errors.messages[:urn].first).to eq(I18n.t("errors.messages.taken"))
    end
  end

  describe "#map_middle_school_phase" do
    let(:school) { build(:school, phase: phase) }

    context "when school is middle-deemed-primary" do
      let(:phase) { "middle_deemed_primary" }

      it "maps to primary" do
        expect(school.map_middle_school_phase).to eq(%w[primary])
      end
    end

    context "when school is middle-deemed-secondayr" do
      let(:phase) { "middle_deemed_secondary" }

      it "maps to secondary" do
        expect(school.map_middle_school_phase).to eq(%w[secondary])
      end
    end

    context "when school is not mapped as middle" do
      let(:phase) { "not_applicable" }

      it "maps to primary secondary" do
        expect(school.map_middle_school_phase).to eq(%w[primary secondary])
      end
    end
  end
end
