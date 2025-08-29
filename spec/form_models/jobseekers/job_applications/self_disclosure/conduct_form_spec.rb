require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe ConductForm, type: :model do
    context "with an empty form" do
      let(:form) { described_class.new }

      it "has the correct errors" do
        expect(form).not_to be_valid
        expect(form.errors.messages).to eq(
          {
            is_known_to_children_services: ["Select no if you have never been known to any children’s services department"],
            has_been_dismissed: ["Select no if you have never been dismissed for misconduct from any paid or voluntary position previously held by you"],
            has_been_disciplined: ["Select no if you have never been under investigation for or subject to any disciplinary sanctions"],
            has_been_disciplined_by_regulatory_body: ["Select no if you have never been subject to any sanctions being placed on your professional registration"],

          },
        )
      end
    end

    context "with an full form" do
      let(:form) do
        described_class.new(is_known_to_children_services: true,
                            has_been_dismissed: true,
                            has_been_disciplined: true,
                            has_been_disciplined_by_regulatory_body: true)
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
