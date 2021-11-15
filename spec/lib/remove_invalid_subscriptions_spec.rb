require "rails_helper"

RSpec.describe RemoveInvalidSubscriptions do
  subject { described_class.new }

  describe "#run!" do
    let(:notify_api_response) do
      [double("response", status: "permanent-failure", email_address: "first@failed.com"),
       double("response", status: "permanent-failure", email_address: "second@failed.com"),
       double("response", status: "not-permanent-failure", email_address: "test@tempfailed.com")]
    end

    let!(:failed_subscription1) { create(:subscription, email: "first@failed.com") }
    let!(:failed_subscription2) { create(:subscription, email: "second@failed.com") }
    let!(:temp_failed_subscription) { create(:subscription, email: "test@tempfailed.com") }

    let(:notify_client_mock) { instance_double(Notifications::Client) }
    let(:notify_notifications_mock) { double("notifications") }

    before do
      allow(Notifications::Client).to receive(:new).with(NOTIFY_KEY).and_return(notify_client_mock)
      allow(notify_client_mock)
        .to receive(:get_notifications).with({ template_type: "email", status: "failed" })
        .and_return(notify_notifications_mock)
      allow(notify_notifications_mock).to receive(:collection).and_return(notify_api_response)
    end

    it "destroys subscriptions with permanently failed email addresses" do
      expect { subject.run! }.to change { Subscription.count }.from(3).to(1)
    end
  end
end
