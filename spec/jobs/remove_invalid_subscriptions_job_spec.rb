require "rails_helper"

RSpec.describe RemoveInvalidSubscriptionsJob do
  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(disable_expensive_jobs_enabled?) }

  context "when DisableExpensiveJobs is not enabled" do
    let(:disable_expensive_jobs_enabled?) { false }

    let(:email_address1) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
    let(:email_address2) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
    let(:email_address3) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }

    let(:notify_api_response) do
      [double("response", email_address: email_address1, id: "email-1"),
       double("response", email_address: email_address2, id: "email-2")]
    end

    let!(:failed_subscription1) { create(:subscription, email: email_address1) }
    let!(:failed_subscription2) { create(:subscription, email: email_address2) }
    let!(:temp_failed_subscription) { create(:subscription, email: email_address3) }

    let(:notify_client_mock) { instance_double(Notifications::Client) }
    let(:notify_notifications_mock) { double("notifications") }

    before do
      allow(Notifications::Client).to receive(:new).and_return(notify_client_mock)
      allow(notify_client_mock)
        .to receive(:get_notifications).with({ template_type: "email", status: "permanent-failure" })
                                       .and_return(notify_notifications_mock)
      allow(notify_notifications_mock).to receive(:collection).and_return(notify_api_response)
      allow(notify_client_mock)
        .to receive(:get_notifications).with({ template_type: "email", status: "permanent-failure", older_than: "email-2" })
                                       .and_return(double("no notifications", collection: []))
    end

    it "destroys subscriptions with permanently failed email addresses" do
      expect { described_class.perform_now }.to change { Subscription.count }.from(3).to(1)
    end
  end

  context "when DisabledExpensiveJobs is enabled" do
    let(:disable_expensive_jobs_enabled?) { true }

    it "does not perform the job" do
      expect(Notifications::Client).not_to receive(:new)

      described_class.perform_now
    end
  end
end
