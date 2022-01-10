require "rails_helper"

RSpec.describe Qualification do
  it { is_expected.to belong_to(:job_application) }

  describe "#name" do
    let(:qualification) { build_stubbed(:qualification, name:, category:) }

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
end
