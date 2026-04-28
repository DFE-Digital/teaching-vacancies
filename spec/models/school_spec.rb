require "rails_helper"

RSpec.describe School do
  it { is_expected.to have_many(:school_group_memberships) }
  it { is_expected.to have_many(:school_groups) }

  describe "#catholic_school?" do
    subject { build(:school, religious_character: religious_character) }

    context "when the religious character is Catholic" do
      let(:religious_character) { "Catholic" }

      it "returns true" do
        expect(subject.catholic_school?).to be true
      end
    end

    context "when the religious character is Roman Catholic" do
      let(:religious_character) { "Roman Catholic" }

      it "returns true" do
        expect(subject.catholic_school?).to be true
      end
    end

    context "when the school has no religious character" do
      let(:religious_character) { "Does not apply" }

      it "returns false" do
        expect(subject.catholic_school?).to be false
      end
    end
  end

  describe "#ats_interstitial_variant" do
    subject { build(:school, religious_character: religious_character) }

    context "when catholic_school? is true" do
      let(:religious_character) { "Catholic" }

      it "returns catholic" do
        expect(subject.ats_interstitial_variant).to eq("catholic")
      end
    end

    context "when faith_school? is true but not catholic" do
      let(:religious_character) { "Church of England" }

      it "returns other_faith" do
        expect(subject.ats_interstitial_variant).to eq("other_faith")
      end
    end

    context "when the school has no faith" do
      let(:religious_character) { "Does not apply" }

      it "returns non_faith" do
        expect(subject.ats_interstitial_variant).to eq("non_faith")
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
