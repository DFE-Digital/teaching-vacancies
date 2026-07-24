require "rails_helper"

RSpec.describe ApplicationMailDeliveryJob do
  let(:email) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
  let(:subscription) { create(:daily_subscription, email:, keyword: "English") }

  describe "wiring" do
    it "is the default delivery job for all mailers" do
      expect(ActionMailer::Base.delivery_job).to eq(described_class)
    end

    it "is the parent of the custom AlertMailerJob so it inherits the retry behaviour" do
      expect(AlertMailerJob.ancestors).to include(described_class)
    end
  end

  describe "retrying transient SSL errors" do
    it "registers OpenSSL::SSL::SSLError as a retry handler" do
      expect(described_class.rescue_handlers.map(&:first)).to include(OpenSSL::SSL::SSLError.name)
    end

    it "registers the same retry handler on the Noticed email delivery job" do
      expect(Noticed::DeliveryMethods::Email.rescue_handlers.map(&:first)).to include("OpenSSL::SSL::SSLError")
    end

    it "re-enqueues instead of failing when a transient SSL error is raised, then succeeds on retry" do
      attempts = 0
      delivery = Jobseekers::SubscriptionMailer.confirmation(subscription)
      allow(Jobseekers::SubscriptionMailer).to receive(:confirmation).and_return(delivery)
      allow(delivery).to receive(:deliver_now) do
        attempts += 1
        raise OpenSSL::SSL::SSLError, "SSL_read: (null) (tls_retry_write_records failure)" if attempts == 1
      end

      expect {
        perform_enqueued_jobs(at: 1.minute.from_now) do
          Jobseekers::SubscriptionMailer.confirmation(subscription).deliver_later
        end
      }.not_to raise_error

      expect(attempts).to eq(2)
    end
  end
end
