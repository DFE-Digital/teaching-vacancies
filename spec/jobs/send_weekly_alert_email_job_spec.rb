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

  context "with multiple vacancies", :perform_enqueued do
    before do
      create(:vacancy, :published_slugged, publish_on: Date.current - 8)
    end

    # rubocop:disable RSpec/VerifiedDoubles
    let(:mail) { double(:mail) }
    # rubocop:enable RSpec/VerifiedDoubles

    let!(:one_week_ago) { create(:vacancy, :published_slugged, publish_on: Date.current - 7) }
    let!(:two_days_ago) { create(:vacancy, :published_slugged, publish_on: Date.yesterday - 1) }
    let!(:yesterday) { create(:vacancy, :published_slugged, publish_on: Date.yesterday) }

    let!(:subscription) { create(:weekly_subscription) }

    it "sends an email" do
      expect(Jobseekers::AlertMailer).to receive(:alert).with(subscription.id, [yesterday, two_days_ago, one_week_ago].map(&:id)) { mail }
      expect(mail).to receive(:deliver_later) { ActionMailer::MailDeliveryJob.new }
      described_class.perform_later
    end
  end
end
