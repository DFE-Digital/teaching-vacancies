require "rails_helper"

RSpec.describe QualificationResult do
  describe "#duplicate" do
    subject(:duplicate) { result.duplicate }

    let(:result) { create(:qualification_result) }

    it "returns a new QualificationResult with the same attributes" do
      %i[
        grade
        subject
      ].each do |attribute|
        expect(duplicate.public_send(attribute)).to eq(result.public_send(attribute))
      end
    end

    it "returns a new unsaved QualificationResult" do
      expect(duplicate).to be_new_record
    end
  end
end
