require "rails_helper"

RSpec.describe GeneralFeedback, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:visit_purpose) }
    it { is_expected.to validate_length_of(:visit_purpose_comment).is_at_most(1200) }

    it { is_expected.to validate_presence_of(:comment) }
    it { is_expected.to validate_length_of(:comment).is_at_most(1200) }

    it { is_expected.to validate_presence_of(:user_participation_response) }
  end

  describe "#email" do
    context "when user is interested in research participation" do
      before { allow(subject).to receive(:user_is_interested?).and_return(true) }
      it { is_expected.to validate_presence_of(:email) }

      it "ensures an email is set" do
        feedback = build(:general_feedback, user_participation_response: :interested)
        feedback.save

        expect(feedback.valid?).to eq(false)
        expect(feedback.errors.messages[:email]).to eq(["Enter your email address"])
      end

      it "ensures a valid email address is used" do
        feedback = build(:general_feedback, user_participation_response: :interested, email: "inv@al@.id.email.com")
        feedback.save

        expect(feedback.valid?).to eq(false)
        expect(feedback.errors.messages[:email]).to eq(
          ["Enter an email address in the correct format, like name@example.com"],
        )
      end
    end

    context "when user is NOT interested in research participation" do
      before { allow(subject).to receive(:user_is_interested?).and_return(false) }
      it { is_expected.not_to validate_presence_of(:email) }
    end
  end
end
