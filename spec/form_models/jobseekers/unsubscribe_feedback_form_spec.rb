require "rails_helper"

RSpec.describe Jobseekers::UnsubscribeFeedbackForm, type: :model do
  it { is_expected.to validate_inclusion_of(:reason).in_array(UnsubscribeFeedback.reasons.keys) }
  it { is_expected.to validate_length_of(:additional_info).is_at_most(1200) }

  context "when reason is job_found" do
    before { allow(subject).to receive(:reason).and_return("job_found") }

    it { is_expected.not_to validate_presence_of(:other_reason) }
  end

  context "when reason is other_reason" do
    before { allow(subject).to receive(:reason).and_return("other_reason") }

    it { is_expected.to validate_presence_of(:other_reason) }
  end
end
