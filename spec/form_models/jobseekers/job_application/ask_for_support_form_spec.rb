require "rails_helper"

RSpec.describe Jobseekers::JobApplication::AskForSupportForm, type: :model do
  subject do
    described_class.new(ask_for_support_section_completed: true)
  end

  context "when support_needed is yes" do
    before { allow(subject).to receive(:is_support_needed).and_return(true) }

    it { is_expected.to validate_presence_of(:support_needed_details) }
  end
end
