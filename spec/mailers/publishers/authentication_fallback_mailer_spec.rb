require "rails_helper"

RSpec.describe Publishers::AuthenticationFallbackMailer do
  describe "the user receives the sign in email containing the magic link" do
    let(:publisher) { create(:publisher) }
    let(:login_key) { publisher.emergency_login_keys.create(not_valid_after: Time.current + 10.minutes) }
    let(:mail) { described_class.sign_in_fallback(login_key_id: login_key.id, publisher:) }
    let(:notify_template) { "2f37ec1d-58ef-4cd9-9d0a-4272723dda3d" }
    let(:expected_data) do
      {
        notify_template:,
        email_identifier: anonymised_form_of(publisher.email),
        user_anonymised_jobseeker_id: nil,
        user_anonymised_publisher_id: anonymised_form_of(publisher.oid),
      }
    end
    let(:body) { mail.body.encoded.downcase }

    it "sends an email with the correct subject, heading, and login link" do
      expect(mail.subject.downcase).to include("sign in to teaching vacancies")
      expect(body).to include("sign in to teaching vacancies")
                  .and include("click the link")
                  .and include("/login_keys/#{login_key.id}")
    end

    it "triggers a `publisher_sign_in_fallback` email event" do
      expect { mail.deliver_now }.to have_triggered_event(:publisher_sign_in_fallback).with_data(expected_data)
    end
  end
end
