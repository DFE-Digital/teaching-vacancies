require "rails_helper"

RSpec.describe SendDailyAlertEmailJob do
  subject(:job) { described_class.perform_later }

  describe "#perform" do
    let(:mail) { double(:mail) }

    context "with vacancies" do
      before do
        create(:vacancy, :published_slugged)
      end

      let(:subscription) { create(:daily_subscription) }

      it "sends an email" do
        expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, Vacancy.pluck(:id)) { mail }
        expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
        perform_enqueued_jobs { job }
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
      expect(Subscription).to receive_message_chain(:active, :daily).and_return(
        Subscription.where(active: true).where(frequency: :daily),
      )
      job.subscriptions
    end
  end
end
