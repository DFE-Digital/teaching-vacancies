require "rails_helper"

RSpec.describe SendWeeklyAlertEmailJob do
  describe "#subscriptions" do
    let(:job) { described_class.new }

    it "gets weekly subscriptions" do
      expect(Subscription).to receive_message_chain(:kept, :weekly).and_return(
        Subscription.kept.where(frequency: :weekly),
      )
      job.subscriptions
    end
  end
end
