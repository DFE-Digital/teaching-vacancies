require "rails_helper"

RSpec.describe Jobseekers::UnsubscribeFeedbackForm, type: :model do
  subject { described_class.new(params) }
  let(:params) do
    {
      comment: "Found a job mate",
      email: "email@example.com",
      unsubscribe_reason: "job_found",
      user_participation_response: "interested",
    }
  end

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to allow_value("email@example.com").for(:email) }
  it { is_expected.to_not allow_value("invalid@email@com").for(:email) }
  it { is_expected.to validate_inclusion_of(:unsubscribe_reason).in_array(Feedback.unsubscribe_reasons.keys) }
  it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
  it {
    is_expected.to validate_inclusion_of(:user_participation_response)
                    .in_array(Feedback.user_participation_responses.keys)
  }

  context "when reason is job_found" do
    before { allow(subject).to receive(:unsubscribe_reason).and_return("job_found") }

    it { is_expected.not_to validate_presence_of(:other_unsubscribe_reason_comment) }
  end

  context "when reason is other_reason" do
    before { allow(subject).to receive(:unsubscribe_reason).and_return("other_reason") }

    it { is_expected.to validate_presence_of(:other_unsubscribe_reason_comment) }
  end
end
