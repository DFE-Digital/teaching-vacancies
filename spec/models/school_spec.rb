require "rails_helper"

RSpec.describe School do
  it { is_expected.to have_many(:school_group_memberships) }
  it { is_expected.to have_many(:school_groups) }

  describe ".available_readable_phases" do
    it "lists all the phases that can be used as human-readable versions of the underlying phase categories, in chronological order" do
      expect(described_class.available_readable_phases).to eq(%w[primary middle secondary 16-19])
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
end
