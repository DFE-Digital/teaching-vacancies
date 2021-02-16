require "rails_helper"

RSpec.describe Publishers::Vacancies::VacancyPublisherFeedbackForm, type: :model do
  subject { described_class.new(params) }
  let(:email) { "helpful@user.com" }
  let(:user_participation_response) { "uninterested" }

  let(:params) do
    {
      comment: "Fancy",
      email: email,
      user_participation_response: user_participation_response,
    }
  end

  it { is_expected.to validate_presence_of(:comment) }
  it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
  it {
    is_expected.to validate_inclusion_of(:user_participation_response)
                        .in_array(Feedback.user_participation_responses.keys)
  }

  describe "#email" do
    context "when the user is interested in participating in user research" do
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
            expect(subject.errors[:email]).to include(I18n.t("vacancy_publisher_feedback_errors.email.invalid"))
          end
        end
      end

      context "and the email is not provided" do
        let(:email) { nil }

        it "is invalid" do
          expect(subject).to be_invalid
          expect(subject.errors[:email]).to include(I18n.t("vacancy_publisher_feedback_errors.email.blank"))
        end
      end
    end
  end
end
