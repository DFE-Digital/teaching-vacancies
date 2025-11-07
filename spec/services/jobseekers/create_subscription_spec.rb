require "rails_helper"

RSpec.describe Jobseekers::CreateSubscription do
  subject(:service) { described_class.new(form, recaptcha_score) }

  let(:form) do
    instance_double(
      Jobseekers::SubscriptionForm,
      job_alert_params: {
        email: "test@contoso.com",
        frequency: "daily",
        search_criteria: { location: "London", radius: "10" },
      },
    )
  end
  let(:recaptcha_score) { 0.9 }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }

  before do
    allow(SetSubscriptionLocationDataJob).to receive(:perform_later)
    allow(Jobseekers::SubscriptionMailer).to receive(:confirmation).and_return(mailer)
  end

  it "creates a subscription with the correct params and recaptcha_score" do
    expect { service.call }.to change(Subscription, :count).from(0).to(1)
    expect(Subscription.last).to have_attributes(
      email: "test@contoso.com",
      frequency: "daily",
      recaptcha_score: recaptcha_score,
      search_criteria: { "location" => "London", "radius" => "10" },
    )
  end

  it "enqueues SetSubscriptionLocationDataJob with the subscription" do
    subscription = described_class.new(form, recaptcha_score).call
    expect(SetSubscriptionLocationDataJob).to have_received(:perform_later).with(subscription).once
  end

  it "sends a confirmation email" do
    subscription = described_class.new(form, recaptcha_score).call
    expect(Jobseekers::SubscriptionMailer).to have_received(:confirmation).with(subscription.id)
    expect(mailer).to have_received(:deliver_later).once
  end
end
