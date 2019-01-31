require 'rails_helper'

RSpec.describe SubscriptionMailer, type: :mailer do
  before(:each) do
    stub_const('NOTIFY_SUBSCRIPTION_CONFIRMATION_TEMPLATE', '')
    Timecop.travel('2019-01-01')
  end

  after(:each) { Timecop.return }

  let(:subscription) do
    create(:daily_subscription, email: 'an@email.com',
                                reference: 'a-reference',
                                search_criteria: {
                                  keyword: 'English',
                                  minimum_salary: 20000,
                                  maximum_salary: 40000,
                                  newly_qualified_teacher: 'true'
                                }.to_json)
  end
  let(:mail) { SubscriptionMailer.confirmation(subscription.id) }
  let(:body_lines) { mail.body.raw_source.lines }

  it 'sends a confirmation email' do
    expect(mail.subject).to eq("Teaching Vacancies subscription confirmation: #{subscription.reference}")
    expect(mail.to).to eq([subscription.email])
    expect(body_lines[0]).to match(/# #{I18n.t('app.title')}/)
    expect(body_lines[1]).to match(/# #{subscription.reference}/)
    expect(body_lines[3]).to match(/#{I18n.t('subscriptions.email.confirmation.subheading')}/)
    expect(body_lines[5]).to match(/\* Keyword: English/)
    expect(body_lines[6]).to match(/\* Minimum Salary: £20,000/)
    expect(body_lines[7]).to match(/\* Maximum Salary: £40,000/)
    expect(body_lines[8]).to match(/\Suitable for NQTs/)
    expect(body_lines[10]).to match(/1 April 2019/)
  end
end
