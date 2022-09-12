require "rails_helper"

RSpec.describe Jobseekers::SubscriptionMailer do
  include ERB::Util

  let(:email) { "an@example.net" }
  let(:search_criteria) { { keyword: "English" } }
  let(:subscription) do
    subscription = Subscription.create(email: email, frequency: "daily", search_criteria: search_criteria)
    # The hashing algorithm uses a random initialization vector to encrypt the token,
    # so is different every time, so we stub the token to be the same every time, so
    # it's clearer what we're testing when we test the unsubscribe link
    token = subscription.token
    allow_any_instance_of(Subscription).to receive(:token) { token }
    subscription
  end

  let(:body) { mail.body }

  let(:expected_data) do
    {
      notify_template: notify_template,
      email_identifier: anonymised_form_of(email),
      user_anonymised_jobseeker_id: user_anonymised_jobseeker_id,
      user_anonymised_publisher_id: nil,
      subscription_identifier: anonymised_form_of(subscription.id),
      uid: "a_unique_identifier",
    }
  end

  # Stub the uid so that we can test links more easily
  before { allow_any_instance_of(ApplicationMailer).to receive(:uid).and_return("a_unique_identifier") }

  describe "#confirmation" do
    let(:mail) { described_class.confirmation(subscription.id) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }
    let(:campaign_params) { { utm_source: "a_unique_identifier", utm_medium: "email", utm_campaign: "jobseeker_subscription_confirmation" } }

    it "sends a confirmation email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.subscription_mailer.confirmation.subject"))
      expect(mail.to).to eq([subscription.email])
      expect(body).to include(I18n.t("jobseekers.subscription_mailer.confirmation.title"))
                  .and include(I18n.t("subscriptions.intro"))
                  .and include("Keyword: English")
                  .and include(I18n.t("jobseekers.subscription_mailer.confirmation.next_steps",
                                      frequency: I18n.t("jobseekers.subscription_mailer.confirmation.frequency.#{subscription.frequency}")))
                  .and include(I18n.t("jobseekers.subscription_mailer.confirmation.unsubscribe_link_text"))
                  .and include(unsubscribe_subscription_url(subscription.token, **campaign_params))
    end

    context "when the subscription email matches a jobseeker account" do
      let(:jobseeker) { create(:jobseeker, email: email) }
      let(:user_anonymised_jobseeker_id) { anonymised_form_of(jobseeker.id) }

      it "triggers a `jobseeker_subscription_confirmation` email event with the anonymised jobseeker id" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_subscription_confirmation).with_data(expected_data)
      end
    end

    context "when the subscription email does not match a jobseeker account" do
      let(:user_anonymised_jobseeker_id) { nil }

      it "triggers a `jobseeker_subscription_confirmation` email event without the anonymised jobseeker id" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_subscription_confirmation).with_data(expected_data)
      end
    end

    describe "create account section" do
      context "when the subscription email matches a jobseeker account" do
        let!(:jobseeker) { create(:jobseeker, email: email) }

        it "does not display create account section" do
          expect(body).not_to include(I18n.t("jobseekers.subscription_mailer.confirmation.create_account.heading"))
        end
      end

      context "when the subscription email does not match a jobseeker account" do
        it "displays create account section" do
          expect(body).to include(I18n.t("jobseekers.subscription_mailer.confirmation.create_account.heading"))
        end
      end
    end
  end

  describe "#update" do
    let(:mail) { described_class.update(subscription.id) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }
    let(:campaign_params) { { utm_source: "a_unique_identifier", utm_medium: "email", utm_campaign: "jobseeker_subscription_update" } }

    it "sends a confirmation email" do
      expect(mail.subject).to eq(I18n.t("jobseekers.subscription_mailer.update.subject"))
      expect(mail.to).to eq([subscription.email])
      expect(body).to include(I18n.t("jobseekers.subscription_mailer.update.title"))
                  .and include(I18n.t("subscriptions.intro"))
                  .and include("Keyword: English")
                  .and include(I18n.t("jobseekers.subscription_mailer.update.next_steps",
                                      frequency: I18n.t("jobseekers.subscription_mailer.confirmation.frequency.#{subscription.frequency}")))
                  .and include(I18n.t("jobseekers.subscription_mailer.update.unsubscribe_link_text"))
                  .and include(unsubscribe_subscription_url(subscription.token, **campaign_params))
    end

    context "when the subscription email matches a jobseeker account" do
      let(:jobseeker) { create(:jobseeker, email: email) }
      let(:user_anonymised_jobseeker_id) { anonymised_form_of(jobseeker.id) }

      it "triggers a `jobseeker_subscription_update` email event with the anonymised jobseeker id" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_subscription_update).with_data(expected_data)
      end
    end

    context "when the subscription email does not match a jobseeker account" do
      let(:user_anonymised_jobseeker_id) { nil }

      it "triggers a `jobseeker_subscription_update` email event without the anonymised jobseeker id" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_subscription_update).with_data(expected_data)
      end
    end

    context "from Sandbox environment" do
      let(:notify_template) { NOTIFY_SANDBOX_TEMPLATE }
      let(:jobseeker) { create(:jobseeker, email: email) }
      let(:user_anonymised_jobseeker_id) { anonymised_form_of(jobseeker.id) }

      before { allow(Rails.configuration).to receive(:app_role).and_return("sandbox") }

      it "triggers a `publisher_sign_in_fallback` email event" do
        expect { mail.deliver_now }.to have_triggered_event(:jobseeker_subscription_update).with_data(expected_data)
      end
    end
  end
end
