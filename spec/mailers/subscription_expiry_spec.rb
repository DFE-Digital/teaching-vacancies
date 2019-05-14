require 'rails_helper'

RSpec.describe SubscriptionExpiryMailer, type: :mailer do
  let(:subscription) do
    subscription = create(:daily_subscription, email: 'an@email.com',
                                               reference: 'a-reference')
    token_attributes = subscription.token_attributes
    allow_any_instance_of(Subscription).to receive(:token_attributes) { token_attributes }
    subscription
  end
  let(:body_lines) { mail.body.raw_source.lines }
  let(:renew_link) { %r{http:\/\/localhost:3000\/subscriptions\/#{subscription.token_attributes}\/renew} }

  describe '#first_expiry_warning' do
    let(:mail) { SubscriptionExpiryMailer.first_expiry_warning(subscription.id) }

    it 'sends a warning email' do
      expect(mail.subject).to eq(
        I18n.t('job_alerts.expiry.email.first_warning.subject', reference: subscription.reference)
      )
      expect(mail.to).to eq([subscription.email])
      expect(body_lines[5]).to match(/#{subscription.reference}/)
      expect(body_lines[7]).to match(/#{I18n.t('job_alerts.expiry.email.first_warning.reset_instructions')}/)
      expect(body_lines[9]).to match(renew_link)
    end
  end

  describe '#final_expiry_warning' do
    let(:mail) { SubscriptionExpiryMailer.final_expiry_warning(subscription.id) }

    it 'sends a warning email' do
      expect(mail.subject).to eq(
        I18n.t('job_alerts.expiry.email.final_warning.subject', reference: subscription.reference)
      )
      expect(mail.to).to eq([subscription.email])
      expect(body_lines[5]).to match(/#{subscription.reference}/)
      expect(body_lines[7]).to match(renew_link)
    end
  end
end