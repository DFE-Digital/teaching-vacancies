require "rails_helper"

RSpec.describe DeleteUnconfirmedSubscriptionsJob do
  describe "#perform" do
    let!(:subscription_to_delete) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_column(:deletion_warning_email_sent_at, 2.months.ago)
      end
    end

    let!(:recently_warned_subscription) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_column(:deletion_warning_email_sent_at, 2.weeks.ago)
      end
    end

    let!(:unwarned_subscription) do
      create(:subscription, frequency: :daily)
    end

    let!(:already_unsubscribed) do
      create(:subscription, frequency: :daily).tap do |s|
        s.update_column(:deletion_warning_email_sent_at, 2.months.ago)
        s.discard
      end
    end

    before do
      described_class.perform_now
    end

    it "destroys subscriptions warned more than 1 month ago" do
      subscription_to_delete.reload
      expect(subscription_to_delete.discarded?).to be(true)
      # unsubscribed_at is our discard column
      expect(subscription_to_delete.unsubscribed_at?).not_to be_nil
    end

    it "does not destroy recently warned subscriptions" do
      expect(Subscription.find(recently_warned_subscription.id)).to eq(recently_warned_subscription)
    end

    it "does not destroy unwarned subscriptions" do
      expect(Subscription.find(unwarned_subscription.id)).to eq(unwarned_subscription)
    end

    it "does not destroy already unsubscribed subscriptions" do
      expect(Subscription.with_discarded.find(already_unsubscribed.id)).to eq(already_unsubscribed)
    end

    it "results in the correct subscription count" do
      # Total created: 4
      # Active remaining: 2 (recently_warned_subscription, unwarned_subscription)
      # Discarded: 2 (already_unsubscribed, not counted by default and subscription_to_delete)
      expect(Subscription.kept.count).to eq(2)
    end
  end
end
