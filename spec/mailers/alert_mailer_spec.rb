require 'rails_helper'

RSpec.describe AlertMailer, type: :mailer do
  include DatesHelper
  include OrganisationHelper
  include ERB::Util

  let(:body) { mail.body.raw_source }
  let(:email) { 'an@email.com' }
  let(:search_criteria) { { keyword: 'English' }.to_json }
  let(:subscription) do
    subscription = Subscription.create(email: email, frequency: frequency, search_criteria: search_criteria)
    # The hashing algorithm uses a random initialization vector to encrypt the token,
    # so is different every time, so we stub the token to be the same every time, so
    # it's clearer what we're testing when we test the unsubscribe link
    token = subscription.token
    allow_any_instance_of(Subscription).to receive(:token) { token }
    subscription
  end
  let(:school) { create(:school) }
  let(:mail) { described_class.alert(subscription.id, vacancies.pluck(:id)) }
  let(:vacancies) { VacanciesPresenter.new(create_list(:vacancy, 2, :published)).decorated_collection }
  let(:campaign_params) { { source: 'subscription', medium: 'email', campaign: "#{frequency}_alert" } }

  before { vacancies.each { |vacancy| vacancy.organisation_vacancies.create(organisation: school) } }

  context 'when frequency is daily' do
    let(:frequency) { :daily }

    before { stub_const('NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE', 'not-nil') }

    it 'sends a job alert email' do
      expect(mail.subject).to eq(I18n.t('alert_mailer.alert.subject'))
      expect(mail.to).to eq([subscription.email])
      expect(mail.body).to include(I18n.t('alert_mailer.alert.summary.daily', count: 2))
      expect(mail.body).to include(vacancies.first.job_title)
      expect(mail.body).to include(vacancies.first.job_title)
      expect(mail.body).to include(vacancies.first.share_url(**campaign_params))
      expect(mail.body).to include(location(vacancies.first.organisation))
      expect(mail.body).to include(I18n.t('alert_mailer.alert.salary', salary: vacancies.first.salary))
      expect(mail.body).to include(I18n.t('alert_mailer.alert.working_pattern', working_pattern: vacancies.first.working_patterns))
      expect(mail.body).to include(I18n.t('alert_mailer.alert.closing_date', closing_date: format_date(vacancies.first.expires_on)))
      expect(mail.body).to include(I18n.t('alert_mailer.alert.title'))
      expect(mail.body).to include(I18n.t('subscriptions.intro'))
      expect(mail.body).to include('Keyword: English')
      expect(mail.body).to include(I18n.t('alert_mailer.alert.alert_frequency', frequency: subscription.frequency))
      expect(mail.body).to include(I18n.t('alert_mailer.alert.edit_link_text'))
      expect(mail.body).to include(edit_subscription_url(subscription.token, protocol: 'https'))
    end
  end

  context 'when frequency is weekly' do
    let(:frequency) { :weekly }

    before { stub_const('NOTIFY_SUBSCRIPTION_WEEKLY_TEMPLATE', 'not-nil') }

    it 'sends a job alert email' do
      expect(mail.subject).to eq(I18n.t('alert_mailer.alert.subject'))
      expect(mail.to).to eq([subscription.email])
      expect(mail.body).to include(I18n.t('alert_mailer.alert.summary.weekly', count: 2))
      expect(mail.body).to include(vacancies.first.job_title)
      expect(mail.body).to include(vacancies.first.job_title)
      expect(mail.body).to include(vacancies.first.share_url(**campaign_params))
      expect(mail.body).to include(location(vacancies.first.organisation))
      expect(mail.body).to include(I18n.t('alert_mailer.alert.salary', salary: vacancies.first.salary))
      expect(mail.body).to include(I18n.t('alert_mailer.alert.working_pattern', working_pattern: vacancies.first.working_patterns))
      expect(mail.body).to include(I18n.t('alert_mailer.alert.closing_date', closing_date: format_date(vacancies.first.expires_on)))
      expect(mail.body).to include(I18n.t('alert_mailer.alert.title'))
      expect(mail.body).to include(I18n.t('subscriptions.intro'))
      expect(mail.body).to include('Keyword: English')
      expect(mail.body).to include(I18n.t('alert_mailer.alert.alert_frequency', frequency: subscription.frequency))
      expect(mail.body).to include(I18n.t('alert_mailer.alert.edit_link_text'))
      expect(mail.body).to include(edit_subscription_url(subscription.token, protocol: 'https'))
    end
  end
end
