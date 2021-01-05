require "rails_helper"

RSpec.describe SubscriptionMailer, type: :mailer do
  include ERB::Util

  let(:email) { "an@email.com" }
  let(:search_criteria) { { keyword: "English" }.to_json }
  let(:subscription) do
    subscription = Subscription.create(email: email, frequency: "daily", search_criteria: search_criteria)
    # The hashing algorithm uses a random initialization vector to encrypt the token,
    # so is different every time, so we stub the token to be the same every time, so
    # it's clearer what we're testing when we test the unsubscribe link
    token = subscription.token
    allow_any_instance_of(Subscription).to receive(:token) { token }
    subscription
  end

  let(:campaign_params) { { utm_source: nil, utm_medium: "email", utm_campaign: "daily_alert" } }
  let(:body) { mail.body }

  describe "#confirmation" do
    let(:mail) { described_class.confirmation(subscription.id) }

    it "sends a confirmation email" do
      expect(mail.subject).to eq(I18n.t("subscription_mailer.confirmation.subject"))
      expect(mail.to).to eq([subscription.email])
      expect(body).to include(I18n.t("subscription_mailer.confirmation.title"))
      expect(body).to include(I18n.t("subscriptions.intro"))
      expect(body).to include("Keyword: English")
      expect(body).to include(I18n.t("subscription_mailer.confirmation.next_steps", frequency: I18n.t("subscription_mailer.confirmation.frequency.#{subscription.frequency}")))
      expect(body).to include(I18n.t("subscription_mailer.confirmation.unsubscribe_link_text"))
      expect(body).to include(unsubscribe_subscription_url(subscription.token, **campaign_params))
    end
  end

  describe "#update" do
    let(:mail) { described_class.update(subscription.id) }

    it "sends a confirmation email" do
      expect(mail.subject).to eq(I18n.t("subscription_mailer.update.subject"))
      expect(mail.to).to eq([subscription.email])
      expect(body).to include(I18n.t("subscription_mailer.update.title"))
      expect(body).to include(I18n.t("subscriptions.intro"))
      expect(body).to include("Keyword: English")
      expect(body).to include(I18n.t("subscription_mailer.update.next_steps", frequency: I18n.t("subscription_mailer.confirmation.frequency.#{subscription.frequency}")))
      expect(body).to include(I18n.t("subscription_mailer.update.unsubscribe_link_text"))
      expect(body).to include(unsubscribe_subscription_url(subscription.token, **campaign_params))
    end
  end
end
