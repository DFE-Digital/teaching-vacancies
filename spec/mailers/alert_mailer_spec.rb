require 'rails_helper'

RSpec.describe AlertMailer, type: :mailer do
  include DatesHelper
  include OrganisationHelper
  include ERB::Util

  let(:body) { mail.body.raw_source }
  let(:subscription) do
    subscription = create(:daily_subscription, email: 'an@email.com',
                                               reference: 'a-reference',
                                               search_criteria: {
                                                 subject: 'English',
                                                 newly_qualified_teacher: 'true'
                                               }.to_json)
    token = subscription.token
    allow_any_instance_of(Subscription).to receive(:token) { token }
    subscription
  end
  let(:school) { create(:school) }

  describe 'daily_alert' do
    before(:each) do
      stub_const('NOTIFY_SUBSCRIPTION_DAILY_TEMPLATE', 'not-nil')
    end

    let(:mail) { described_class.daily_alert(subscription.id, vacancies.pluck(:id)) }
    let(:vacancies) { create_list(:vacancy, 1, :published) }
    let(:campaign_params) { { source: 'subscription', medium: 'email', campaign: 'daily_alert' } }

    before do
      vacancies.each { |vacancy| vacancy.organisation_vacancies.create(organisation: school) }
    end

    context 'with a single vacancy' do
      let(:vacancy_presenter) { VacancyPresenter.new(vacancies.first) }

      it 'shows a vacancy' do
        expect(mail.subject).to eq(
          I18n.t(
            'job_alerts.alert.email.daily.subject.one',
            reference: subscription.reference
          )
        )
        expect(mail.to).to eq([subscription.email])

        expect(body).to match(/# #{I18n.t('app.title')}/)
        expect(body).to match(
          /A new job matching your search criteria &#39;#{subscription.reference}&#39; was posted yesterday/
        )
        expect(body).to match(/---/)
        expect(body).to match(/#{Regexp.escape(vacancy_presenter.share_url(campaign_params))}/)
        expect(body).to match(/#{html_escape(location(vacancies.first.organisation))}/)

        expect(body).to match(/#{vacancy_presenter.working_patterns}/)

        expect(body).to match(/#{format_date(vacancy_presenter.expires_on)}/)
        expect(body).to include(subscription_unsubscribe_url(subscription_id: subscription.token, protocol: 'http'))
      end
    end

    context 'with multiple vacancies' do
      let(:vacancies) { create_list(:vacancy, 2, :published) }
      let(:first_vacancy_presenter) { VacancyPresenter.new(vacancies.first) }
      let(:second_vacancy_presenter) { VacancyPresenter.new(vacancies.last) }

      before do
        vacancies.each { |vacancy| vacancy.organisation_vacancies.create(organisation: school) }
      end

      it 'shows vacancies' do
        expect(mail.subject).to eq(
          I18n.t(
            'job_alerts.alert.email.daily.subject.many',
            reference: subscription.reference
          )
        )
        expect(mail.to).to eq([subscription.email])

        expect(body).to match(/\[#{first_vacancy_presenter.job_title}\]/)
        expect(body).to match(/#{Regexp.escape(first_vacancy_presenter.share_url(campaign_params))}/)
        expect(body).to match(/#{html_escape(location(vacancies.first.organisation))}/)
        expect(body).to match(/#{first_vacancy_presenter.working_patterns}/)
        expect(body).to match(/#{format_date(first_vacancy_presenter.expires_on)}/)

        expect(body).to match(/\[#{second_vacancy_presenter.job_title}\]/)
        expect(body).to match(/#{Regexp.escape(second_vacancy_presenter.share_url(campaign_params))}/)
        expect(body).to match(/#{html_escape(location(vacancies.last.organisation))}/)
        expect(body).to match(/#{second_vacancy_presenter.working_patterns}/)
        expect(body).to match(/#{format_date(second_vacancy_presenter.expires_on)}/)
      end
    end
  end
end
