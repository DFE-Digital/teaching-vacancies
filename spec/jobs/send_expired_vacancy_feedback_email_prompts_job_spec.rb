require "rails_helper"

RSpec.describe SendExpiredVacancyFeedbackEmailJob do
  subject(:job) { described_class.perform_later }
  let(:mail) { double("Mail::Message", deliver_later: true) }

  before do
    allow(Publishers::FeedbackPromptMailer).to receive(:prompt_for_feedback) { mail }
  end

  context "for one publisher" do
    let(:user) { create(:publisher, email: email_of_publishers) }
    let(:email_of_publishers) { "email@example.com" }

    context "with one expired vacancy needing feedback" do
      let!(:expired_vacancy) { create(:vacancy, :expired, publisher: user, expires_at: Time.current) }

      it "sends an email" do
        expect(Publishers::FeedbackPromptMailer).to receive(:prompt_for_feedback).with(user, [expired_vacancy])
        expect(mail).to receive(:deliver_later)
        send_expired_vacancy_feedback_emails
      end

      context "but the publisher has no email address" do
        let(:email_of_publishers) { nil }

        it "does not send an email" do
          expect(Publishers::FeedbackPromptMailer).to_not receive(:prompt_for_feedback)
          send_expired_vacancy_feedback_emails
        end
      end
    end

    context "with one expired vacancy with feedback already completed" do
      let!(:expired_vacancies) do
        create(:vacancy, :expired, :with_feedback, expires_at: Time.current, publisher: user)
      end

      it "does not send an email" do
        expect(Publishers::FeedbackPromptMailer).to_not receive(:prompt_for_feedback)
        send_expired_vacancy_feedback_emails
      end
    end

    context "with two expired vacancies needing feedback" do
      let!(:expired_vacancies) do
        [create(:vacancy, :expired, expires_at: Time.current, publisher: user),
         create(:vacancy, :expired, expires_at: Time.current, publisher: user)]
      end

      it "sends an email with both vacancies" do
        expect(Publishers::FeedbackPromptMailer).to receive(:prompt_for_feedback).with(
          user,
          a_collection_containing_exactly(*expired_vacancies),
        )
        send_expired_vacancy_feedback_emails
      end
    end

    context "running the job before publishers have had 2 weeks opportunity to fill in feedback" do
      let!(:expired_vacancy) do
        create(:vacancy, :expired, expires_at: Time.current, publisher: user)
      end

      it "sends no emails" do
        expect(Publishers::FeedbackPromptMailer).to_not receive(:prompt_for_feedback)

        send_expired_vacancy_feedback_emails 1.week
      end
    end
  end

  context "for two publishers" do
    let(:first_publisher) { create(:publisher, email: "first_publishers@example.net") }
    let(:second_publisher) { create(:publisher, email: "second_publishers@example.net") }

    context "with one expired vacancy each" do
      let(:first_expired_vacancy) do
        create(:vacancy, :expired, expires_at: Time.current, publisher: first_publisher)
      end

      let(:second_expired_vacancy) do
        create(:vacancy, :expired, expires_at: Time.current, publisher: second_publisher)
      end

      it "sends one email for each publisher" do
        expect(Publishers::FeedbackPromptMailer).to receive(:prompt_for_feedback).with(first_publisher, [first_expired_vacancy])
        expect(Publishers::FeedbackPromptMailer).to receive(:prompt_for_feedback).with(second_publisher, [second_expired_vacancy])
        send_expired_vacancy_feedback_emails
      end
    end
  end

  context "without a publisher" do
    context "with one expired vacancy needing feedback" do
      let!(:expired_vacancy) { create(:vacancy, :expired, expires_at: Time.current, publisher: nil) }

      it "does not send an email" do
        expect(Publishers::FeedbackPromptMailer).to_not receive(:prompt_for_feedback)
        send_expired_vacancy_feedback_emails
      end
    end
  end

  def send_expired_vacancy_feedback_emails(after = 2.weeks)
    travel after do
      perform_enqueued_jobs { job }
    end
  end
end
