require "rails_helper"

RSpec.describe SendExpiredVacancyFeedbackPromptJob do
  subject(:job) { described_class.perform_later }
  let(:expiry_date) { 3.weeks.ago }
  let(:mail) { double("Mail::Message", deliver_later: true) }
  let(:publisher) { create(:publisher, email: publisher_email) }
  let(:publisher_email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }

  before { allow(Publishers::ExpiredVacancyFeedbackPromptMailer).to receive(:prompt_for_feedback).and_return(mail) }

  context "when the publisher has 5 or less vacancies to be prompted on" do
    let!(:expired_vacancy1) { create(:vacancy, :expired, publisher: publisher, expires_at: expiry_date) }
    let!(:expired_vacancy2) { create(:vacancy, :expired, publisher: publisher, expires_at: expiry_date) }

    before { create(:vacancy, :expired, publisher: publisher, expires_at: 1.day.ago) }

    context "when the email notifications are enabled" do
      it "sends an email with vacancies that expired between 2 weeks ago and the cutoff date" do
        expect(Publishers::ExpiredVacancyFeedbackPromptMailer).to receive(:prompt_for_feedback).with(publisher, expired_vacancy1)
        expect(mail).to receive(:deliver_later)

        perform_enqueued_jobs { job }
      end

      it "sets the timestamp" do
        perform_enqueued_jobs { job }
        [expired_vacancy1, expired_vacancy2].each(&:reload)

        expect([expired_vacancy1, expired_vacancy2].map(&:expired_vacancy_feedback_email_sent_at)).to_not include(nil)
      end
    end

    context "when email notifications are disabled", :disable_email_notifications do
      it "does not send an email" do
        expect(Publishers::ExpiredVacancyFeedbackPromptMailer).to_not receive(:prompt_for_feedback)

        perform_enqueued_jobs { job }
      end

      it "does not set the timestamp" do
        perform_enqueued_jobs { job }
        [expired_vacancy1, expired_vacancy2].each(&:reload)

        expect([expired_vacancy1, expired_vacancy2].map(&:expired_vacancy_feedback_email_sent_at)).to all(be_nil)
      end
    end

    context "when the publisher has no email address" do
      let(:publisher_email) { nil }

      it "does not send an email" do
        expect(Publishers::ExpiredVacancyFeedbackPromptMailer).to_not receive(:prompt_for_feedback)

        perform_enqueued_jobs { job }
      end
    end

    context "when the publisher has unsubscribed from the emails" do
      before { publisher.update(unsubscribed_from_expired_vacancy_prompt_at: 1.day.ago) }

      it "does not send an email" do
        expect(Publishers::ExpiredVacancyFeedbackPromptMailer).to_not receive(:prompt_for_feedback)

        perform_enqueued_jobs { job }
      end
    end
  end
end
