require "rails_helper"

RSpec.describe RemoveInvalidSubscriptionsJob do
  let(:notify_client_mock) { instance_double(Notifications::Client) }

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_client_mock)
  end

  describe "removing bounced subscriptions" do
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

    let(:notify_notifications_mock) { double("notifications") }

    before do
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

  describe "removing discards" do
    let(:notify_client_mock) { instance_double(Notifications::Client, get_notifications: double(collection: [])) }
    let(:active_jobseeker) { create(:jobseeker) }
    let(:inactive_jobseeker) { create(:jobseeker, :with_closed_account) }
    let!(:inactive_for_closed) { create(:subscription, :inactive, email: inactive_jobseeker.email) }
    let!(:inactive_for_open) { create(:subscription, :inactive, email: active_jobseeker.email) }
    let!(:inactive_without_account) { create(:subscription, :inactive) }
    let!(:active_subscription) { create(:subscription, email: active_jobseeker.email) }

    before do
      described_class.perform_now
    end

    it "destroys inactive subscriptions for active jobseekers and those without accounts" do
      expect(Subscription.all).to contain_exactly(active_subscription, inactive_for_closed)
    end
  end

  context "when the integrations are disabled", :disable_integrations do
    it "does not perform the job" do
      expect(Notifications::Client).not_to receive(:new)

      described_class.perform_now
    end
  end
end
