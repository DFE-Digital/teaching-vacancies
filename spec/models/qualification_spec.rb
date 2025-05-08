require "rails_helper"

RSpec.describe Qualification do
  it { is_expected.to belong_to(:job_application).optional }
  it { is_expected.to belong_to(:jobseeker_profile).optional }

  describe "#remove_inapplicable_data" do
    subject(:qualification) do
      build(:qualification,
            finished_studying: finished_studying,
            grade: "Merit",
            year: 2020,
            month: 6,
            finished_studying_details: "Current student")
    end

    before { qualification.remove_inapplicable_data }

    context "when finished_studying is true clears finished_studying_details" do
      let(:finished_studying) { true }

      it { expect(qualification.finished_studying_details).to be_blank }
      it { expect(qualification.grade).to eq("Merit") }
      it { expect(qualification.year).to eq(2020) }
      it { expect(qualification.month).to eq(6) }
    end

    context "when finished_studying is false clears grade, year and month" do
      let(:finished_studying) { false }

      it { expect(qualification.finished_studying_details).to eq("Current student") }
      it { expect(qualification.grade).to be_blank }
      it { expect(qualification.year).to be_blank }
      it { expect(qualification.month).to be_blank }
    end

    context "when finished_studying is nil does not modify any fields" do
      let(:finished_studying) { nil }

      it { expect(qualification.finished_studying_details).to eq("Current student") }
      it { expect(qualification.grade).to eq("Merit") }
      it { expect(qualification.year).to eq(2020) }
      it { expect(qualification.month).to eq(6) }
    end
  end

  describe "#name" do
    let(:qualification) { build_stubbed(:qualification, name: name, category: category) }

    context "when the category is 'other'" do
      let(:category) { "other" }
      let(:name) { "Welsh Baccalaureate" }

      context "when the name has been set" do
        it "returns the raw name attribute" do
          expect(qualification.name).to eq(name)
        end
      end

      context "when the name has not been set" do
        let(:name) { "" }

        it "is blank" do
          expect(qualification.name).to be_blank
        end
      end
    end

    context "when the category is not 'other' and the name has not been set" do
      let(:category) { "undergraduate" }
      let(:name) { "" }

      it "returns the correct translation" do
        expect(qualification.name).to eq("Undergraduate degree")
      end
    end
  end

  describe "#duplicate" do
    subject(:duplicate) { qualification.duplicate }
    let(:qualification) { create(:qualification) }

    it "returns a new Qualification with the same attributes" do
      %i[
        category
        finished_studying_details
        finished_studying
        grade
        institution
        name
        subject
        year
        month
      ].each do |attribute|
        expect(duplicate.public_send(attribute)).to eq(qualification.public_send(attribute))
      end
    end

    it "copies over the qualification results" do
      expect(duplicate.qualification_results.flat_map(&:subject).sort)
        .to eq(qualification.qualification_results.flat_map(&:subject).sort)
    end

    it "returns a new unsaved Qualification" do
      expect(duplicate).to be_new_record
    end

    it "does not copy job application associations" do
      expect(duplicate.job_application).to be_nil
    end

    it "does not copy jobseeker profile associations" do
      expect(duplicate.jobseeker_profile).to be_nil
    end
  end

  describe "#display_attributes" do
    subject(:display_attributes) { qualification.display_attributes }

    context "when qualification is secondary" do
      let(:qualification) { build_stubbed(:qualification, category: "gcse") }

      it { is_expected.to match_array(%w[institution award_date]) }
    end

    context "when qualification is not secondary and finished_studying is true" do
      let(:qualification) { build_stubbed(:qualification, category: "undergraduate", finished_studying: true, awarding_body: "uni") }

      it { is_expected.to match_array(%w[subject institution grade award_date awarding_body]) }
    end

    context "when qualification is not secondary and finished_studying is false" do
      let(:qualification) { build_stubbed(:qualification, category: "undergraduate", finished_studying: false, awarding_body: "uni") }

      it { is_expected.to match_array(%w[subject institution awarding_body]) }
    end
  end

  describe "#award_date" do
    subject(:award_date) { qualification.award_date }

    context "when month and year are present" do
      let(:qualification) { build_stubbed(:qualification, year: 2020, month: 6) }

      it { is_expected.to eq("June 2020") }
    end

    context "when only year is present" do
      let(:qualification) { build_stubbed(:qualification, year: 2020, month: nil) }

      it { is_expected.to eq("2020") }
    end

    context "when neither month nor year is present" do
      let(:qualification) { build_stubbed(:qualification, year: nil, month: nil) }

      it { is_expected.to be_blank }
    end
  end
end
