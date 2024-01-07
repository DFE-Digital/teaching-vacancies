require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe Publishers::AuthenticationFallbackMailer do
  describe "the user receives the sign in email containing the magic link" do
    let(:publisher) { create(:publisher) }
    let(:login_key) { publisher.emergency_login_keys.create(not_valid_after: Time.current + 10.minutes) }
    let(:mail) { described_class.sign_in_fallback(login_key_id: login_key.id, publisher: publisher) }
    let(:notify_template) { NOTIFY_PRODUCTION_TEMPLATE }
    let(:expected_data) do
      {
        notify_template: notify_template,
        email_identifier: anonymised_form_of(publisher.email),
        user_anonymised_jobseeker_id: nil,
        user_anonymised_publisher_id: anonymised_form_of(publisher.oid),
      }
    end
    let(:body) { mail.body.encoded.downcase }

    it "sends an email with the correct subject" do
      expect(mail.subject.downcase).to include("sign in to teaching vacancies")
    end

    it "sends an email with the correct heading, and login link" do
      expect(body).to include("sign in to teaching vacancies")
                  .and include("click the link")
                  .and include("/login_keys/#{login_key.id}")
    end

    it "triggers a `publisher_sign_in_fallback` email event" do
      mail.deliver_now
      expect(:publisher_sign_in_fallback).to have_been_enqueued_as_analytics_events
    end
  end
end
