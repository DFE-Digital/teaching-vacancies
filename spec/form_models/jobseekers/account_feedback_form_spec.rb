require "rails_helper"

RSpec.describe Jobseekers::AccountFeedbackForm, type: :model do
  it { is_expected.to validate_inclusion_of(:rating).in_array(Feedback.ratings.keys) }
  it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
  it { is_expected.to allow_value("email@example").for(:email) }
  it { is_expected.to validate_inclusion_of(:report_a_problem).in_array(%w[yes no]) }
  it { is_expected.to validate_inclusion_of(:user_participation_response)
                    .in_array(Feedback.user_participation_responses.keys)
  }

  describe "#email" do
    context "when the jobseeker is interested in participating in research" do
      before { allow(subject).to receive(:user_participation_response).and_return("interested") }

      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to_not allow_value("invalid@email@com").for(:email) }
    end

    context "when the jobseeker is uninterested in participating in research" do
      before { allow(subject).to receive(:user_participation_response).and_return("uninterested") }

      it { is_expected.not_to validate_presence_of(:email) }
    end
  end
end
