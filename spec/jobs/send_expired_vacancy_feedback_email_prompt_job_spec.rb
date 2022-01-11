require "rails_helper"

RSpec.describe SendExpiredVacancyFeedbackPromptJob do
  subject(:job) { described_class.perform_later }
  let(:expiry_date) { 3.weeks.ago }
  let(:mail) { double("Mail::Message", deliver_later: true) }
  let(:publisher) { create(:publisher, email: publisher_email) }
  let(:publisher_email) { "test@example.com" }

  before { allow(Publishers::ExpiredVacancyFeedbackPromptMailer).to receive(:prompt_for_feedback).and_return(mail) }

  context "when the publisher has 5 or less vacancies to be prompted on" do
    let!(:expired_vacancies) { create_list(:vacancy, 4, :expired, publisher: publisher, expires_at: expiry_date) }

    before { create(:vacancy, :expired, publisher: publisher, expires_at: 1.day.ago) }

    it "sends an email with vacancies that expired between 2 weeks ago and the cutoff date" do
      expect(Publishers::ExpiredVacancyFeedbackPromptMailer).to receive(:prompt_for_feedback).with(publisher, a_collection_containing_exactly(*expired_vacancies))
      expect(mail).to receive(:deliver_later)

      perform_enqueued_jobs { job }
    end

    it "sets the timestamp" do
      perform_enqueued_jobs { job }
      expired_vacancies.each(&:reload)
      
      expect(expired_vacancies.map(&:expired_vacancy_feedback_email_sent_at)).to_not include(nil)
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

  context "with more than 5 vacancies matching the criteria" do
    let!(:oldest_expired_vacancies) { create_list(:vacancy, 5, :expired, publisher: publisher, expires_at: expiry_date) }

    before do
      create(:vacancy, :expired, publisher: publisher, expires_at: expiry_date + 1.day)
      create(:vacancy, :expired, publisher: publisher, expires_at: expiry_date + 2.days)
      create(:vacancy, :expired, publisher: publisher, expires_at: 1.day.ago)
    end

    it "sends an email with the 5 oldest expired vacancies" do
      expect(publisher.vacancies.count).to eq(8)

      expect(Publishers::ExpiredVacancyFeedbackPromptMailer).to receive(:prompt_for_feedback).with(publisher, a_collection_containing_exactly(*oldest_expired_vacancies))
      expect(mail).to receive(:deliver_later)

      perform_enqueued_jobs { job }
    end
  end
end
