require "rails_helper"

RSpec.describe Jobseekers::JobApplication::AskForSupportForm, type: :model do
  it { is_expected.to validate_inclusion_of(:support_needed).in_array(%w[yes no]) }

  context "when support_needed is yes" do
    before { allow(subject).to receive(:support_needed).and_return("yes") }

    it { is_expected.to validate_presence_of(:support_details) }
  end

  context "when support_needed is no" do
    context "when params contains support_details" do
      subject { described_class.new({ support_needed: "no", support_details: "Some misplaced details" }) }

      it "sets support_details to nil" do
        expect(subject.support_details).to be_blank
      end
    end
  end
end
