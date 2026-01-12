require "rails_helper"

RSpec.describe SendSubscriptionGovernanceEmailsJob do
  let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

  describe "#perform" do
    let!(:old_subscription) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_column(:updated_at, 13.months.ago)
      end
    end

    let!(:recent_subscription) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_column(:updated_at, 6.months.ago)
      end
    end

    let!(:already_warned_subscription) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_column(:updated_at, 13.months.ago)
        s.update_column(:deletion_warning_email_sent_at, 2.weeks.ago)
      end
    end

    let!(:unsubscribed_subscription) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_column(:updated_at, 13.months.ago)
        s.discard
      end
    end

    context "with unregistered jobseeker, never updated subscription" do
      it "sends governance_email_unregistered_never_updated" do
        expect(Jobseekers::SubscriptionMailer)
          .to receive(:governance_email_unregistered_never_updated)
          .with(old_subscription)
          .and_return(message_delivery)

        expect(message_delivery).to receive(:deliver_later)

        described_class.perform_now

        expect(old_subscription.reload.deletion_warning_email_sent_at).not_to be_nil
      end
    end

    context "with unregistered jobseeker, updated subscription" do
      let!(:old_subscription) do
        create(:subscription, frequency: :daily).tap do |s|
          s.update_column(:created_at, 14.months.ago)
          s.update_column(:updated_at, 13.months.ago)
        end
      end

      it "sends governance_email_unregistered_was_updated" do
        expect(Jobseekers::SubscriptionMailer)
          .to receive(:governance_email_unregistered_was_updated)
          .with(old_subscription)
          .and_return(message_delivery)

        expect(message_delivery).to receive(:deliver_later)

        described_class.perform_now

        expect(old_subscription.reload.deletion_warning_email_sent_at).not_to be_nil
      end
    end

    context "with registered jobseeker, never updated subscription" do
      let!(:jobseeker) { create(:jobseeker, email: old_subscription.email.downcase) }

      it "sends governance_email_registered_never_updated" do
        expect(Jobseekers::SubscriptionMailer)
          .to receive(:governance_email_registered_never_updated)
          .with(old_subscription)
          .and_return(message_delivery)

        expect(message_delivery).to receive(:deliver_later)

        described_class.perform_now

        expect(old_subscription.reload.deletion_warning_email_sent_at).not_to be_nil
      end
    end

    context "with registered jobseeker, updated subscription" do
      let!(:old_subscription) do
        create(:subscription, frequency: :daily).tap do |s|
          s.update_column(:created_at, 14.months.ago)
          s.update_column(:updated_at, 13.months.ago)
        end
      end
      let!(:jobseeker) { create(:jobseeker, email: old_subscription.email.downcase) }

      it "sends governance_email_registered_was_updated" do
        expect(Jobseekers::SubscriptionMailer)
          .to receive(:governance_email_registered_was_updated)
          .with(old_subscription)
          .and_return(message_delivery)

        expect(message_delivery).to receive(:deliver_later)

        described_class.perform_now

        expect(old_subscription.reload.deletion_warning_email_sent_at).not_to be_nil
      end
    end

    context "when email notifications are disabled", :disable_email_notifications do
      it "does not send emails" do
        expect(Jobseekers::SubscriptionMailer)
          .not_to receive(:governance_email_unregistered_never_updated)

        described_class.perform_now
      end
    end

    it "does not send emails to recent subscriptions" do
      expect(Jobseekers::SubscriptionMailer)
        .to receive(:governance_email_unregistered_never_updated)
        .with(old_subscription)
        .and_return(message_delivery)

      expect(message_delivery).to receive(:deliver_later)

      described_class.perform_now

      expect(recent_subscription.reload.deletion_warning_email_sent_at).to be_nil
    end

    it "does not send emails to already warned subscriptions" do
      expect(Jobseekers::SubscriptionMailer)
        .to receive(:governance_email_unregistered_never_updated)
        .with(old_subscription)
        .and_return(message_delivery)

      expect(message_delivery).to receive(:deliver_later)

      described_class.perform_now

      expect(already_warned_subscription.reload.deletion_warning_email_sent_at).to eq(already_warned_subscription.deletion_warning_email_sent_at)
    end

    it "does not send emails to unsubscribed subscriptions" do
      expect(Jobseekers::SubscriptionMailer)
        .to receive(:governance_email_unregistered_never_updated)
        .with(old_subscription)
        .and_return(message_delivery)

      expect(message_delivery).to receive(:deliver_later)

      described_class.perform_now

      expect(unsubscribed_subscription.reload.deletion_warning_email_sent_at).to be_nil
    end
  end
end
