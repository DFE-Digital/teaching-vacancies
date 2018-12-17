require 'rails_helper'
require 'subscription_confirmation_email'

RSpec.describe SubscriptionConfirmationEmail do
  before(:each) do
    stub_const('NOTIFY_SUBSCRIPTION_CONFIRMATION_TEMPLATE', '')
    Timecop.travel('2019-01-01')
  end

  after(:each) { Timecop.return }

  it 'correctly generates the email content' do
    subscription = create(:daily_subscription, email: 'an@email.com',
                                               reference: 'a-reference',
                                               search_criteria: { keyword: 'English' }.to_json)
    personalisation = { subscription_reference: subscription.reference,
                        body: "# Teaching Vacancies\n# You have subscribed to email notifications " \
                              "for jobs that match the following search criteria:\nKeyword: English\n\n" \
                              "Your subscription will expire in 3 months, on the  1 April 2019.\n" }

    notify = double(:notify, call: nil)
    expect(Notify).to receive(:new).with(subscription.email, personalisation, '', 'subscription_confirmation')
                                   .and_return(notify)

    SubscriptionConfirmationEmail.new(subscription).call
  end
end
