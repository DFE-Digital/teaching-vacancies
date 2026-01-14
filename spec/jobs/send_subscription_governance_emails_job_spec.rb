require "rails_helper"

RSpec.describe SendSubscriptionGovernanceEmailsJob do
  let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

  describe "#perform" do
    let!(:old_subscription) { create(:subscription, frequency: :daily) }

    let!(:recent_subscription) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_column(:updated_at, 6.months.ago)
      end
    end

    let!(:already_warned_subscription) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_columns(created_at: 13.months.ago, updated_at: 13.months.ago)
        s.update_column(:deletion_warning_email_sent_at, 2.weeks.ago)
      end
    end

    let!(:unsubscribed_subscription) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_columns(created_at: 13.months.ago, updated_at: 13.months.ago)
        s.discard
      end
    end

    let!(:already_warned_subscription_deletion_email_sent_at) { already_warned_subscription.deletion_warning_email_sent_at }

    it "sends governance_email_unregistered_never_updated to unregistered, never updated subscriptions" do
      old_subscription.update_columns(created_at: 13.months.ago, updated_at: 13.months.ago)

      expect(Jobseekers::SubscriptionMailer)
        .to receive(:governance_email_unregistered_never_updated)
        .with(have_attributes(id: old_subscription.id))
        .and_return(message_delivery)

      expect(message_delivery).to receive(:deliver_later)

      described_class.perform_now

      expect(old_subscription.reload.deletion_warning_email_sent_at).not_to be_nil
      expect(recent_subscription.reload.deletion_warning_email_sent_at).to be_nil
      expect(already_warned_subscription.reload.deletion_warning_email_sent_at).to eq(already_warned_subscription_deletion_email_sent_at)
      expect(unsubscribed_subscription.reload.deletion_warning_email_sent_at).to be_nil
    end

    it "sends governance_email_unregistered_was_updated to unregistered, updated subscriptions" do
      old_subscription.update_columns(created_at: 14.months.ago, updated_at: 13.months.ago)

      expect(Jobseekers::SubscriptionMailer)
        .to receive(:governance_email_unregistered_was_updated)
        .with(have_attributes(id: old_subscription.id))
        .and_return(message_delivery)

      expect(message_delivery).to receive(:deliver_later)

      described_class.perform_now

      expect(old_subscription.reload.deletion_warning_email_sent_at).not_to be_nil
      expect(recent_subscription.reload.deletion_warning_email_sent_at).to be_nil
      expect(already_warned_subscription.reload.deletion_warning_email_sent_at).to eq(already_warned_subscription_deletion_email_sent_at)
      expect(unsubscribed_subscription.reload.deletion_warning_email_sent_at).to be_nil
    end

    it "sends governance_email_registered_never_updated to registered, never updated subscriptions" do
      old_subscription.update_columns(created_at: 13.months.ago, updated_at: 13.months.ago)
      jobseeker = create(:jobseeker, email: old_subscription.email.downcase)

      expect(jobseeker).to be_present

      expect(Jobseekers::SubscriptionMailer)
        .to receive(:governance_email_registered_never_updated)
        .with(have_attributes(id: old_subscription.id))
        .and_return(message_delivery)

      expect(message_delivery).to receive(:deliver_later)

      described_class.perform_now

      expect(old_subscription.reload.deletion_warning_email_sent_at).not_to be_nil
      expect(recent_subscription.reload.deletion_warning_email_sent_at).to be_nil
      expect(already_warned_subscription.reload.deletion_warning_email_sent_at).to eq(already_warned_subscription_deletion_email_sent_at)
      expect(unsubscribed_subscription.reload.deletion_warning_email_sent_at).to be_nil
    end

    it "sends governance_email_registered_was_updated to registered, updated subscriptions" do
      old_subscription.update_columns(created_at: 14.months.ago, updated_at: 13.months.ago)
      jobseeker = create(:jobseeker, email: old_subscription.email.downcase)

      expect(jobseeker).to be_present

      expect(Jobseekers::SubscriptionMailer)
        .to receive(:governance_email_registered_was_updated)
        .with(have_attributes(id: old_subscription.id))
        .and_return(message_delivery)

      expect(message_delivery).to receive(:deliver_later)

      described_class.perform_now

      expect(old_subscription.reload.deletion_warning_email_sent_at).not_to be_nil
      expect(recent_subscription.reload.deletion_warning_email_sent_at).to be_nil
      expect(already_warned_subscription.reload.deletion_warning_email_sent_at).to eq(already_warned_subscription_deletion_email_sent_at)
      expect(unsubscribed_subscription.reload.deletion_warning_email_sent_at).to be_nil
    end

    context "when email notifications are disabled", :disable_email_notifications do
      it "does not send emails" do
        old_subscription.update_columns(created_at: 13.months.ago, updated_at: 13.months.ago)

        expect(Jobseekers::SubscriptionMailer)
          .not_to receive(:governance_email_unregistered_never_updated)

        described_class.perform_now
      end
    end
  end
end
