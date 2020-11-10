require "rails_helper"

RSpec.describe SendExpiredVacancyFeedbackEmailJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }
  let(:mail) { double("Mail::Message", deliver_later: true) }

  before do
    allow(FeedbackPromptMailer).to receive(:prompt_for_feedback) { mail }
  end

  context "when adding job to the queue" do
    it "queues the job" do
      expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it "is in the email_feedback_prompt queue" do
      expect(job.queue_name).to eq("email_feedback_prompt")
    end
  end

  context "for one hiring staff" do
    let(:user) { create(:user, email: email_of_hiring_staff) }
    let(:email_of_hiring_staff) { "email@example.com" }

    context "with one expired vacancy needing feedback" do
      let!(:expired_vacancy) { create(:vacancy, :expired, publisher_user: user, expires_on: Date.current) }

      it "sends an email" do
        expect(FeedbackPromptMailer).to receive(:prompt_for_feedback).with(email_of_hiring_staff, [expired_vacancy])
        expect(mail).to receive(:deliver_later)
        send_expired_vacancy_feedback_emails
      end

      context "but the hiring staff has no email address" do
        let(:email_of_hiring_staff) { nil }

        it "does not send an email" do
          expect(FeedbackPromptMailer).to_not receive(:prompt_for_feedback)
          send_expired_vacancy_feedback_emails
        end
      end
    end

    context "with one expired vacancy with feedback already completed" do
      let!(:expired_vacancies) do
        create(:vacancy, :expired, :with_feedback, expires_on: Date.current, publisher_user: user)
      end

      it "does not send an email" do
        expect(FeedbackPromptMailer).to_not receive(:prompt_for_feedback)
        send_expired_vacancy_feedback_emails
      end
    end

    context "with two expired vacancies needing feedback" do
      let!(:expired_vacancies) do
        [create(:vacancy, :expired, expires_on: Date.current, publisher_user: user),
         create(:vacancy, :expired, expires_on: Date.current, publisher_user: user)]
      end

      it "sends an email with both vacancies" do
        expect(FeedbackPromptMailer).to receive(:prompt_for_feedback).with(
          email_of_hiring_staff,
          a_collection_containing_exactly(*expired_vacancies),
        )
        send_expired_vacancy_feedback_emails
      end
    end

    context "running the job before hiring staff have had 2 weeks opportunity to fill in feedback" do
      let!(:expired_vacancy) do
        create(:vacancy, :expired, expires_on: Date.current, publisher_user: user)
      end

      it "sends no emails" do
        expect(FeedbackPromptMailer).to_not receive(:prompt_for_feedback)

        send_expired_vacancy_feedback_emails 1.week
      end
    end
  end

  context "for two hiring staff" do
    let(:first_hiring_staff) { create(:user, email: "first_hiring_staff@email.com") }
    let(:second_hiring_staff) { create(:user, email: "second_hiring_staff@email.com") }

    context "with one expired vacancy each" do
      let(:first_expired_vacancy) do
        create(:vacancy, :expired, expires_on: Date.current, publisher_user: first_hiring_staff)
      end

      let(:second_expired_vacancy) do
        create(:vacancy, :expired, expires_on: Date.current, publisher_user: second_hiring_staff)
      end

      it "sends one email for each hiring staff" do
        expect(FeedbackPromptMailer).to receive(:prompt_for_feedback).with(
          first_hiring_staff.email,
          [first_expired_vacancy],
        )
        expect(FeedbackPromptMailer).to receive(:prompt_for_feedback).with(
          second_hiring_staff.email,
          [second_expired_vacancy],
        )
        send_expired_vacancy_feedback_emails
      end
    end
  end

  context "without a publisher hiring staff" do
    context "with one expired vacancy needing feedback" do
      let!(:expired_vacancy) { create(:vacancy, :expired, expires_on: Date.current, publisher_user: nil) }

      it "does not send an email" do
        expect(FeedbackPromptMailer).to_not receive(:prompt_for_feedback)
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
