require "rails_helper"

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
      expect { mail.deliver_now }.to have_triggered_event(:publisher_sign_in_fallback).with_data(expected_data)
    end

    context "from Sandbox environment" do
      let(:notify_template) { NOTIFY_SANDBOX_TEMPLATE }

      before do
        allow(Rails.env).to receive(:sandbox?).and_return(true)
      end

      it "triggers a `publisher_sign_in_fallback` email event" do
        expect { mail.deliver_now }.to have_triggered_event(:publisher_sign_in_fallback).with_data(expected_data)
      end
    end
  end
end
