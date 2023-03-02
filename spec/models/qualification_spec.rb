require "rails_helper"

RSpec.describe Qualification do
  it { is_expected.to belong_to(:job_application).optional }
  it { is_expected.to belong_to(:jobseeker_profile).optional }

  describe "#name" do
    let(:qualification) { build_stubbed(:qualification, name: name, category: category) }

    context "when the category is 'other_secondary' or 'other'" do
      let(:category) { "other_secondary" }
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

    context "when the category is not 'other_secondary' or 'other' and the name has not been set" do
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
      ].each do |attribute|
        expect(duplicate.public_send(attribute)).to eq(qualification.public_send(attribute))
      end
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
end
