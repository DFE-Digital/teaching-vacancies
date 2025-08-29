require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe ConfirmationForm, type: :model do
    context "with an empty form" do
      let(:form) { described_class.new }

      it "has the correct errors" do
        expect(form).not_to be_valid
        expect(form.errors.messages).to eq(
          {
            agreed_for_processing: ["Agree for your information to be processed in order to complete the declaration"],
            agreed_for_criminal_record: ["Agree criminal record option in order to complete the declaration"],
            agreed_for_organisation_update: ["Agree to update the school in order to complete the declaration"],
            agreed_for_information_sharing: ["Agree for information sharing in order to complete the declaration"],
            true_and_complete: ["Agree that information is true and complete in order to complete the declaration"],
          },
        )
      end
    end

    context "with an full form" do
      let(:form) do
        described_class.new(agreed_for_processing: true,
                            agreed_for_criminal_record: true,
                            agreed_for_organisation_update: true,
                            agreed_for_information_sharing: true,
                            true_and_complete: true)
      end

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
