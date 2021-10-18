require "rails_helper"

RSpec.describe Jobseekers::JobApplication::FeedbackForm, type: :model do
  subject { described_class.new(params) }
  let(:params) do
    {
      email: "email@example.com",
      rating: "neither",
      user_participation_response: "interested",
    }
  end

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to allow_value("email@example.com").for(:email) }
  it { is_expected.to_not allow_value("invalid@email@com").for(:email) }
  it { is_expected.to validate_inclusion_of(:rating).in_array(Feedback.ratings.keys) }
  it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
  it {
    is_expected.to validate_inclusion_of(:user_participation_response)
                    .in_array(Feedback.user_participation_responses.keys)
  }
end
