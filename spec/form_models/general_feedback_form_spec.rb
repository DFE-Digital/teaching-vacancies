require "rails_helper"

RSpec.describe GeneralFeedbackForm, type: :model do
  subject { described_class.new(params) }
  let(:email) { "helpful@user.com" }
  let(:user_participation_response) { "uninterested" }
  let(:visit_purpose) { "find_teaching_job" }
  let(:visit_purpose_comment) { nil }
  let(:params) do
    {
      comment: "Fancy",
      email: email,
      user_participation_response: user_participation_response,
      visit_purpose: visit_purpose,
      visit_purpose_comment: visit_purpose_comment,
    }
  end

  it { is_expected.to validate_presence_of(:comment) }
  it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
  it {
    is_expected.to validate_inclusion_of(:user_participation_response)
                  .in_array(Feedback.user_participation_responses.keys)
  }
  it { is_expected.to validate_inclusion_of(:visit_purpose).in_array(Feedback.visit_purposes.keys) }
  it { is_expected.to validate_length_of(:visit_purpose_comment).is_at_most(1200) }

  describe "#email" do
    context "when the user is uninterested in participating in user research" do
      let(:email) { nil }

      it "allows email to be blank" do
        expect(subject).to be_valid
      end
    end

    context "when the user is interested in participating in user research" do
      let(:user_participation_response) { "interested" }

      context "and the email is provided" do
        it "is valid" do
          expect(subject).to be_valid
        end

        context "and the email is invalid" do
          let(:email) { "invalid@email@com" }

          it "ensures a valid email address is used" do
            expect(subject).to be_invalid
            expect(subject.errors[:email]).to include(I18n.t("general_feedback_errors.email.invalid"))
          end
        end
      end

      context "and the email is not provided" do
        let(:email) { nil }

        it "is invalid" do
          expect(subject).to be_invalid
          expect(subject.errors[:email]).to include(I18n.t("general_feedback_errors.email.blank"))
        end
      end
    end
  end

  describe "#visit_purpose_comment" do
    context "when the visit purpose is not 'other_purpose'" do
      it { is_expected.not_to validate_presence_of(:visit_purpose_comment) }
    end

    context "when the visit purpose is 'other_purpose'" do
      let(:visit_purpose) { "other_purpose" }

      it { is_expected.to validate_presence_of(:visit_purpose_comment) }
    end
  end
end
