require "rails_helper"

RSpec.describe SendDailyAlertEmailJob do
  subject(:job) { described_class.perform_later }

  describe "#perform" do
    let(:mail) { double(:mail) }

    context "with vacancies" do
      before do
        create(:vacancy, :published_slugged, publish_on: Date.yesterday)
      end

      let(:subscription) { create(:daily_subscription) }

      it "sends an email" do
        expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, PublishedVacancy.pluck(:id)) { mail }
        expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
        perform_enqueued_jobs { job }
      end

      context "when subscription does not have an email address" do
        before do
          subscription.update!(email: nil)
        end

        it "does not send an email" do
          expect(Jobseekers::AlertMailer).to_not receive(:alert).with(subscription.id, PublishedVacancy.pluck(:id)) { mail }
          perform_enqueued_jobs { job }
        end
      end

      context "when a run exists" do
        before do
          create(:alert_run, subscription: subscription, run_on: Date.current)
        end

        it "does not send another email" do
          expect(Jobseekers::AlertMailer).to_not receive(:alert)
          perform_enqueued_jobs { job }
        end
      end

      context "when email notifications are disabled", :disable_email_notifications do
        it "does not send an email or create a run" do
          expect(Jobseekers::AlertMailer).to_not receive(:alert)
          perform_enqueued_jobs { job }
          expect(subscription.alert_runs.count).to eq(0)
        end
      end
    end

    context "with no vacancies" do
      let(:subscription) { create(:subscription, frequency: :daily) }

      it "does not send an email or create a run" do
        expect(Jobseekers::AlertMailer).to_not receive(:alert)
        perform_enqueued_jobs { job }
        expect(subscription.alert_runs.count).to eq(0)
      end
    end
  end

  describe "#subscriptions" do
    let(:job) { described_class.new }

    it "gets active daily subscriptions" do
      expect(Subscription).to receive_message_chain(:kept, :daily).and_return(
        Subscription.kept.where(frequency: :daily),
      )
      job.subscriptions
    end
  end
end
