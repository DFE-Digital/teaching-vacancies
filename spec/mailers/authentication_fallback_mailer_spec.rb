require "rails_helper"

RSpec.describe AuthenticationFallbackMailer, type: :mailer do
  describe "the user receives the sign in email containing the magic link" do
    let(:user) { create(:publisher) }
    let(:login_key) { user.emergency_login_keys.create(not_valid_after: Time.current + 10.minutes) }
    let(:mail) { described_class.sign_in_fallback(login_key: login_key, email: user.email) }

    before { mail.deliver_later }

    it "sends an email with the correct subject, heading, and login link" do
      expect(mail.subject.downcase).to include("sign in to teaching vacancies")

      body = mail.body.encoded.downcase

      # Heading
      expect(body).to include("sign in to teaching vacancies")
      # Paragraph
      expect(body).to include("click the link")
      # Login link
      expect(body).to include("/auth/email/sessions/choose-organisation?login_key=#{login_key.id}")
    end
  end
end
