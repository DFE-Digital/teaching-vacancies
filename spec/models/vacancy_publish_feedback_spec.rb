require "rails_helper"

RSpec.describe VacancyPublishFeedback, type: :model do
  it { should belong_to(:vacancy) }
  it { should belong_to(:publisher) }

  describe "validations" do
    it { should validate_presence_of(:comment) }
    it { should validate_length_of(:comment).is_at_most(1200) }
  end

  describe "#email" do
    context "when user is interested in research participation" do
      before { allow(subject).to receive(:user_is_interested?).and_return(true) }
      it { is_expected.to validate_presence_of(:email) }

      it "ensures an email is set" do
        feedback = build(:vacancy_publish_feedback, user_participation_response: :interested)
        feedback.save

        expect(feedback.valid?).to eq(false)
        expect(feedback.errors.messages[:email]).to eq(["Enter your email address"])
      end

      it "ensures a valid email address is used" do
        feedback = build(:vacancy_publish_feedback,
                         user_participation_response: :interested,
                         email: "inv@al@.id.email.com")
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

  describe "#published_on(date)" do
    it "retrieves feedback submitted on the given date" do
      feedback_today = create_list(:vacancy_publish_feedback, 3)
      feedback_yesterday = create_list(:vacancy_publish_feedback, 2, created_at: 1.day.ago)
      feedback_the_other_day = create_list(:vacancy_publish_feedback, 4, created_at: 2.days.ago)
      feedback_some_other_day = create_list(:vacancy_publish_feedback, 6, created_at: 1.month.ago)

      expect(VacancyPublishFeedback.published_on(Date.current).all).to match_array(feedback_today)
      expect(VacancyPublishFeedback.published_on(1.day.ago)).to match_array(feedback_yesterday)
      expect(VacancyPublishFeedback.published_on(2.days.ago)).to match_array(feedback_the_other_day)
      expect(VacancyPublishFeedback.published_on(1.month.ago)).to match_array(feedback_some_other_day)
    end
  end
end
