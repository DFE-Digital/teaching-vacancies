require 'rails_helper'

RSpec.describe SubscriptionMailer, type: :mailer do
  include ERB::Util

  before(:each) do
    stub_const('NOTIFY_SUBSCRIPTION_CONFIRMATION_TEMPLATE', '')
    Timecop.travel('2019-01-01')
  end

  after(:each) { Timecop.return }

  let(:email) { 'an@email.com' }
  let(:subscription) do
    subscription = create(:daily_subscription, email: email,
                                               reference: 'a-reference',
                                               search_criteria: {
                                                 subject: 'English',
                                                 newly_qualified_teacher: 'true'
                                               }.to_json)
    # The hashing algorithm uses a random initialization vector to encrypt the token,
    # so is different every time, so we stub the token to be the same every time, so
    # it's clearer what we're testing when we test the unsubscribe link
    token = subscription.token
    allow_any_instance_of(Subscription).to receive(:token) { token }
    subscription
  end
  let(:mail) { SubscriptionMailer.confirmation(subscription.id) }
  let(:body_lines) { mail.body.raw_source.lines }

  it 'sends a confirmation email' do
    expect(mail.subject).to eq(I18n.t('job_alerts.confirmation.email.subject', reference: subscription.reference))
    expect(mail.to).to eq([subscription.email])
    expect(body_lines[0]).to match(/# #{I18n.t('app.title')}/)
    expect(body_lines[1]).to match(
      /#{html_escape(I18n.t('subscriptions.email.confirmation.heading', reference: subscription.reference))}/
    )
    expect(body_lines[3]).to match(/#{I18n.t('subscriptions.email.confirmation.subheading', email: email)}/)
    expect(body_lines[5]).to match(/\* Subject: English/)
    expect(body_lines[6]).to match(/\Suitable for NQTs/)
    expect(body_lines[8]).to include('You&#39;ll receive a single job alert email at the end of any day')
  end

  it 'has an unsubscribe link' do
    expect(body_lines[10]).to match(/#{I18n.t('subscriptions.email.unsubscribe_text_html')}/)
    expect(body_lines[12]).to match(%r{http:\/\/localhost:3000\/subscriptions\/#{subscription.token}\/unsubscribe})
  end
end
