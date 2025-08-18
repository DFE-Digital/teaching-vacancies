require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe BarredListForm, type: :model do
    context "with an empty form" do
      let(:form) { described_class.new }

      it "has the correct errors" do
        expect(form).not_to be_valid
        expect(form.errors.messages).to eq(
          {
            is_barred: ["Select no if you have not been included on the list of people barred from/listed as unsuitable to engage in regulated activity/work with children"],
            has_been_referred: ["Select no if you have not been referred to the Disclosure and Barring Service"],
          },
        )
      end
    end

    context "with an full form" do
      let(:form) do
        described_class.new(is_barred: true,
                            has_been_referred: true)
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
