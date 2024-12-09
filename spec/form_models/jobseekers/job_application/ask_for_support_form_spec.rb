require "rails_helper"

RSpec.describe Jobseekers::JobApplication::AskForSupportForm, type: :model do
  subject do
    described_class.new(ask_for_support_section_completed: true)
  end

  it { is_expected.to validate_inclusion_of(:support_needed).in_array(%w[yes no]) }

  context "when support_needed is yes" do
    before { allow(subject).to receive(:support_needed).and_return("yes") }

    it { is_expected.to validate_presence_of(:support_needed_details) }
  end
end
