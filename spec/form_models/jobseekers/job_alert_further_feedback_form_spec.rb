require "rails_helper"

RSpec.describe Jobseekers::JobAlertFurtherFeedbackForm, type: :model do
  subject { described_class.new(params) }
  let(:user_participation_response) { "interested" }
  let(:params) do
    {
      comment: "Found a job mate",
      email: "email@example.com",
      user_participation_response: user_participation_response,
    }
  end

  it { is_expected.to validate_presence_of(:comment) }
  it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
  it {
    is_expected.to validate_inclusion_of(:user_participation_response)
                  .in_array(Feedback.user_participation_responses.keys)
  }


  context "when the user_participation_response == 'interested'" do
    it { is_expected.to validate_presence_of(:occupation) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value("email@example.com").for(:email) }
    it { is_expected.to_not allow_value("invalid@email@com").for(:email) }
  end

  context "when the user_participation_response != 'interested'" do
    let(:user_participation_response) { "uninterested" }

    it { is_expected.not_to validate_presence_of(:email) }
    it { is_expected.not_to validate_presence_of(:occupation) }
  end
end
