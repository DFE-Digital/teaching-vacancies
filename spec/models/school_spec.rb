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

  describe "#fe_college?" do
    it "returns true when the school matches the colleges scope" do
      expect(build(:college)).to be_fe_college
    end

    it "returns false when the school type does not match the colleges scope" do
      expect(build(:school, detailed_school_type: School::FE_DETAILED_SCHOOL_TYPE)).not_to be_fe_college
    end

    it "returns false when the detailed school type does not match the colleges scope" do
      expect(build(:school, school_type: School::COLLEGE_SCHOOL_TYPE)).not_to be_fe_college
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
